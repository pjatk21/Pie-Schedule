//
//  ContentView.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    private let altapi = AltapiManager()
    
    @ObservedResults(ScheduleEntry.self) var entries
    @Environment(\.realm) var realm: Realm
    
    var body: some View {
        NavigationView {
            List(entries) { entry in
                VStack(alignment: .leading) {
                    Text(entry.code ?? "Nieokreślono")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text(entry.name ?? "Nieokreślono")
                        .font(.system(size: 12))
                        .italic()
                    HStack {
                        Text(entry.beginDate.formatted(date: .omitted, time: .shortened))
                        Text(entry.room ?? "Brak sali")
                    }
                    
                }
            }
            .refreshable {
                let r = try! await altapi.getEntries(for: "2022-03-07")
                try! realm.write {
                    realm.deleteAll()
                    realm.add(r!.entries)
                }
            }
            .navigationTitle("Plan zajęć")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if !ScheduleEntry.previewsPopulated {
            ScheduleEntry.preloadPreview()
        }
        return ContentView()
            .environment(\.realmConfiguration, Realm.Configuration( deleteRealmIfMigrationNeeded: true))
    }
}
