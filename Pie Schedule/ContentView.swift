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
            WelcomeSheetPageRow(imageSystemName: "calendar", title: String(localized: "Your new schedule"), content: String(localized: "2010webAppCringe", comment: "Say how cringe is using outdated software")),
            WelcomeSheetPageRow(imageSystemName: "hare", title: String(localized: "Fast as ****"), content: String(localized: "apiFast", comment: "Tell how fast this API is"))
        ]),
        WelcomeSheetPage(title: String(localized: "🇵🇱🇺🇦🇬🇧"), rows: [
            WelcomeSheetPageRow(imageSystemName: "airplane.departure", title: String(localized: "Timezone aware"), content: String(localized: "timezoneAwareDesciption", comment: "Say how timezones work")),
            WelcomeSheetPageRow(imageSystemName: "character.bubble", title: String(localized: "Polyglot"), content: String(localized: "appTranslateForCommunityByCommunity", comment: "Say that app has been translated into many languages"))
        ])
    ]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(activeDate: .now)
            .environment(\.realm, .previews)
    }
}
