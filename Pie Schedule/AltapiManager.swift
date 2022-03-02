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
    private let urlSession: URLSession
    private let baseUrl = URL(string: "https://altapi.kpostek.dev/")!
    private var realm: Realm
    
    init(urlSessionConfig: URLSessionConfiguration = .default, realmConfig: Realm.Configuration = .prodConfig) {
        realm = try! Realm(configuration: realmConfig)
        urlSession = URLSession(configuration: urlSessionConfig)
    }
    
    static let backgroundMode = AltapiManager(urlSessionConfig: .background(withIdentifier: BackgroundTasks.refreshTaskId))
    
    func updateEntries(for date: Date) async throws -> ScheduleEntryResponse? {
        // create url and query
        let dateString = date.toFormat("yyyy-MM-dd")
        let url = baseUrl.appendingPathComponent("public/timetable/date/\(dateString)")
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        
        urlComp.queryItems = realm.objects(ScheduleGroup.self).map {
            URLQueryItem(name: "groups", value: $0.name)
        }
        guard let urlFinal = urlComp.url else { return nil }
        print(urlFinal)
        
        // remove old data
        let outdated = realm.objects(ScheduleEntry.self).where {
            $0.begin > date.date && $0.begin < date.dateAtEndOf(.day).date
        }
        try realm.write {
            realm.delete(outdated)
        }
        
        // save new data
        let (data, _) = try await urlSession.data(from: urlFinal)
        
        // Funny thing, Apple uses ISO8601 without seconds fractions, how cruel...
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decode in
            let container = try decode.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = dateString.toISODate() {
                return date.date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "This string \(dateString) is not a valid ISO string.")
        })
        
        let result = try decoder.decode(ScheduleEntryResponse.self, from: data)
        let realmAsync = try await Realm(configuration: .prodConfig)
        try realmAsync.write {
            realmAsync.add(result.entries)
        }
        
        return result
    }
    
    func getAvailableGroups() async throws -> AvailableGroupsResponse {
        let url = baseUrl.appendingPathComponent("public/timetable/groups")
        let (data, _) = try await urlSession.data(from: url)
        return (try? JSONDecoder().decode(AvailableGroupsResponse.self, from: data)) ?? AvailableGroupsResponse(groupsAvailable: ["WIs I.2 - 46c"])
    }
    
    func updateGroups() async throws -> [ScheduleGroup] {
        let oldGroupsNames = realm.objects(ScheduleGroup.self).where{
            $0.assingned
        }.map {
            $0.name
        }
        let newGroups = try await self.getAvailableGroups().groupsAvailable.map { newGroupName -> ScheduleGroup in
            let newGroup = ScheduleGroup()
            newGroup.name = newGroupName
            if oldGroupsNames.filter({ $0 == newGroupName }).first != nil {
                newGroup.assingned = true
            }
            return newGroup
        }
        try realm.write {
            realm.delete(realm.objects(ScheduleGroup.self))
            realm.add(newGroups)
        }
        return newGroups
    }
}
