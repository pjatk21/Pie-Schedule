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
    @AppStorage("pref.autoskip") private var skipToNextDate = true
    @AppStorage("pref.fetchSize") private var fetchSize = 7
    
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
        .welcomeSheet(isPresented: $showSheet, onDismiss: {}, isSlideToDismissDisabled: true, pages: pages)
        .onAppear {
            guard skipToNextDate else {
                return
            }
            
            if let newDate = nextDayWithClasses() {
                activeDate = newDate
            }
        }
        .task {
            let _ = await updateScheduleInRange()
        }
    }
    
    func updateScheduleInRange() async -> ScheduleEntryResponse? {
        return try! await altapi.updateEntries(from: .now.dateAtStartOf(.day), to: (Date() + fetchSize.days).dateAtEndOf(.day))
    }

    func entriesActive() -> Results<ScheduleEntry> {
        entries.where { $0.begin > activeDate && $0.begin < activeDate.dateAtEndOf(.day) }
    }
    
    func nextDayWithClasses() -> Date? {
        return realm.objects(ScheduleEntry.self).where {
            $0.begin > Date().dateAtStartOf(.day)
        }.sorted(by: \.begin).first?.begin.dateAtStartOf(.day)
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
