//
//  ContentView.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift
import SwiftDate
import SwiftUI

struct ContentView: View {
    private let altapi = AltapiManager()

    @ObservedResults(ScheduleEntry.self) var entries
    @Environment(\.realm) var realm: Realm
    @State var activeDate = Date().dateBySet(hour: 0, min: 0, secs: 0)!

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
    }

    func entriesActive() -> Results<ScheduleEntry> {
        entries.where { $0.begin > activeDate && $0.begin < activeDate.dateAtEndOf(.day) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleEntry.preloadPreview()
        return ContentView(activeDate: Date(year: 2022, month: 3, day: 7, hour: 0, minute: 0))
            .environment(\.realmConfiguration, Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    }
}
