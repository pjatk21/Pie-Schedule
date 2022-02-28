//
//  ContentView.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift
import SwiftDate
import SwiftUI
import WelcomeSheet

struct ContentView: View {
    private let altapi = AltapiManager()

    @ObservedResults(ScheduleEntry.self) var entries
    @Environment(\.realm) var realm: Realm
    @State var activeDate = Date().dateBySet(hour: 0, min: 0, secs: 0)!
    @AppStorage("first.launch") private var showSheet = true

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        activeDate = activeDate - 1.days
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                            .padding(.horizontal, 25.0)
                    }
                    DatePicker("Date", selection: $activeDate, displayedComponents: [.date])
                        .datePickerStyle(DefaultDatePickerStyle())
                    Button {
                        activeDate = activeDate + 1.days
                    } label: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                            .padding(.horizontal, 25.0)
                    }
                }
                List(entriesActive()) { entry in
                    EntryPreviewRow(entry: entry)
                }
                .refreshable {
                    let _ = try! await altapi.updateEntries(for: activeDate)
                }
            }
            .navigationTitle("Plan zajęć")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Settings()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .welcomeSheet(isPresented: $showSheet, onDismiss: {}, isSlideToDismissDisabled: false, pages: pages)
    }

    func entriesActive() -> Results<ScheduleEntry> {
        entries.where { $0.begin > activeDate && $0.begin < activeDate.dateAtEndOf(.day) }
    }
    
    private let pages = [
        WelcomeSheetPage(title: "Pie Schedule", rows: [
            WelcomeSheetPageRow(imageSystemName: "calendar", title: "Twoja nowa aplikacja do planu zajęć", content: "Już nigdy nie tykaj tej webowej apki z 2010"),
            WelcomeSheetPageRow(imageSystemName: "hare", title: "Ekstermalnie szybkie API", content: "Czas odpowiedzi API z zajęciami jest nawet 90x krótszy niż czas odpowiedzi strony z planem zajęć. Nie bój się, że nie będziesz mógł/mógła sprawdzić, swojego planu zajęć.")
        ]),
        WelcomeSheetPage(title: "Pie Schedule", rows: [
            WelcomeSheetPageRow(imageSystemName: "airplane.departure", title: "Zawsze na czas", content: "Aplikacja uwzględnia twoją aktualną strefę czasową, nie musisz już przeliczać kiedy rozpoczyna się wykład."),
            WelcomeSheetPageRow(imageSystemName: "character.bubble", title: "Poliglota", content: "Aplikacja dzięki wsparciu społeczności została przetłumacznona na takie jęzki jak ukraiński/białoruski")
        ])
    ]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleEntry.preloadPreview()
        return ContentView(activeDate: Date(year: 2022, month: 3, day: 7, hour: 0, minute: 0))
            .environment(\.realmConfiguration, Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    }
}
