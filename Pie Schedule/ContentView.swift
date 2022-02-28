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
            .navigationTitle("Schedule")
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
        WelcomeSheetPage(title: String(localized: "Pie Schedule is fast!"), rows: [
            WelcomeSheetPageRow(imageSystemName: "calendar", title: String(localized: "Your new schedule"), content: String(localized: "Forget about that web app from 2010.")),
            WelcomeSheetPageRow(imageSystemName: "hare", title: String(localized: "Fast as ****"), content: String(localized: "API response times are even 90x faster compared to the response time of orginal web service."))
        ]),
        WelcomeSheetPage(title: String(localized: "Pie Schedule is multilingual 🇵🇱🇺🇦🇬🇧"), rows: [
            WelcomeSheetPageRow(imageSystemName: "airplane.departure", title: String(localized: "Timezone aware"), content: String(localized: "All dates and times has timezone offset, so you don't have to count it all the time, when you are aboard.")),
            WelcomeSheetPageRow(imageSystemName: "character.bubble", title: String(localized: "Polyglot"), content: String(localized: "App has been translated to the multiple languages, thanks to: community."))
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
