//
//  ContentView.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import SwiftUI
import RealmSwift
import SwiftDate

struct ContentView: View {
    private let altapi = AltapiManager()
    
    @ObservedResults(ScheduleEntry.self) var entries
    @Environment(\.realm) var realm: Realm
    @State var activeDate = Date()
    
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
                    Text(activeDate.formatted(date: .abbreviated, time: .omitted))
                        .frame(maxWidth: .infinity)
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
                List(entries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.code ?? "Nieokreślono")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text((entry.name ?? "Nieokreślono") + (entry.type ?? ""))
                            .font(.system(size: 12))
                            .italic()
                        HStack {
                            Text(entry.beginDate.formatted(date: .omitted, time: .shortened))
                            Text(entry.room ?? "Brak sali")
                        }
                        
                    }
                }
                .refreshable {
                    let r = try! await altapi.getEntries(for: activeDate.toFormat("yyyy-MM-dd"))
                    try! realm.write {
                        realm.deleteAll()
                        realm.add(r!.entries)
                    }
                }
            }
            .navigationTitle("Plan zajęć")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleEntry.preloadPreview()
        return ContentView()
            .environment(\.realmConfiguration, Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    }
}
