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
    @State var activeDate = Date().dateAtStartOf(.day)
    @AppStorage("first.launch") private var showSheet = true

    var body: some View {
        NavigationView {
            VStack {
                DateControl(activeDate: $activeDate)
                List(entriesActive()) { entry in
                    NavigationLink(destination: EntryDetailsView(scheduleEntry: entry)) {
                        EntryPreviewRow(entry: entry)
                            .padding(.vertical)
                    }
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
        .navigationViewStyle(.stack)
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
        ContentView(activeDate: .now)
            .environment(\.realm, .previews)
    }
}
