//
//  AltapiManager.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import Foundation
import RealmSwift
import SwiftDate

class AltapiManager {
    private let urlSession = URLSession(configuration: .default)
    private let baseUrl = URL(string: "https://altapi.kpostek.dev/")!
    private var realm = try! Realm(configuration: .init(deleteRealmIfMigrationNeeded: true))
    
    func updateEntries(for date: Date) async throws -> ScheduleEntryResponse? {
        return try await updateEntries(for: date.toFormat("yyyy-MM-dd"))
    }
    
    func updateEntries(for dateString: String) async throws -> ScheduleEntryResponse? {
        // create url and query
        let url = baseUrl.appendingPathComponent("public/timetable/\(dateString)")
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if realm.objects(ScheduleGroup.self).count == 0 {
            let a = ScheduleGroup()
            a.raw = "WIs I.2 - 46c"
            let b = ScheduleGroup()
            b.raw = "WIs I.2 - 1w"
            try realm.write {
                realm.add([a, b])
            }
        }
        
        
        urlComp.queryItems = realm.objects(ScheduleGroup.self).map {
            URLQueryItem(name: "groups", value: $0.raw)
        }
        guard let urlFinal = urlComp.url else { return nil }
        print(urlFinal)
        
        // remove old data
        let outdated = realm.objects(ScheduleEntry.self).where {
            $0.dateString == dateString
        }
        try realm.write {
            realm.delete(outdated)
        }
        
        // save new data
        let (data, _) = try await urlSession.data(from: urlFinal)
        let result = try JSONDecoder().decode(ScheduleEntryResponse.self, from: data)
        let realmAsync = try await Realm(configuration: self.realm.configuration)
        try realmAsync.write {
            realmAsync.add(result.entries)
        }
        
        return result
    }
}
