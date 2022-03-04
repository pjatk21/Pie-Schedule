//
//  AltapiManager.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import Foundation
@preconcurrency import RealmSwift
import SwiftDate
import os.log

class AltapiManager: ObservableObject {
    private let urlSession = URLSession(configuration: .default)
    private let baseUrl = URL(string: "https://altapi.kpostek.dev/v1")!
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Altapi Manager")
    private var realm: Realm
    
    init(realmConfig: Realm.Configuration = .prodConfig) {
        realm = try! Realm(configuration: realmConfig)
    }
    
    private func isoDateDecodingStrategy(decode: Decoder) throws -> Date {
        let container = try decode.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        if let date = dateString.toISODate() {
            return date.date
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "This string \(dateString) is not a valid ISO string.")
    }
    
    var hasGroupsConfigured: Bool {
        realm.objects(ScheduleGroup.self).count > 0
    }
    
    private func sinkNewScheduleEntries(newEntries: [ScheduleEntry]) async throws {
        let realmAsync = try await Realm(configuration: .prodConfig)
        let newEntriesSorted = newEntries.sorted {
            $0.begin < $1.begin
        }
        
        // find data to replace
        logger.debug("Removing entries from \(newEntriesSorted.first?.begin.toISO() ?? "???") to \(newEntriesSorted.last?.begin.toISO() ?? "???")")
        let outdatedEntries = realm.objects(ScheduleEntry.self).where {
            $0.begin >= newEntriesSorted.first?.begin ?? Date() && $0.begin <= newEntriesSorted.last?.begin ?? Date()
        }
        
        try realmAsync.write {
            realmAsync.delete(outdatedEntries)
            realmAsync.add(newEntriesSorted)
        }
    }
    
    func updateEntries(for date: Date) async throws -> ScheduleEntryResponse? {
        return try await self.updateEntries(from: date.dateAtStartOf(.day), to: date.dateAtEndOf(.day))
    }
    
    func updateEntries(from begin: Date, to end: Date) async throws -> ScheduleEntryResponse? {
        // Prevent unwanted fetch of whole schedule
        guard hasGroupsConfigured else {
            return .init(entries: [])
        }
        
        // Create query
        let url = baseUrl.appendingPathComponent("timetable/range")
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        urlComp.queryItems = realm.objects(ScheduleGroup.self).map {
            URLQueryItem(name: "groups", value: $0.name)
        }
        
        urlComp.queryItems?.append(
            URLQueryItem(name: "from", value: begin.toISO())
        )
        urlComp.queryItems?.append(
            URLQueryItem(name: "to", value: end.toISO())
        )
        
        // Perform request
        guard let urlFinal = urlComp.url else { return nil }
        logger.notice("Query is \(urlFinal)")
        
        let (data, _) = try await urlSession.data(from: urlFinal)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(self.isoDateDecodingStrategy)
        
        // Save data to realm
        let result = try decoder.decode(ScheduleEntryResponse.self, from: data)
        try await self.sinkNewScheduleEntries(newEntries: result.entries)
        
        return result
    }
    
    func getAvailableGroups() async throws -> AvailableGroupsResponse {
        let url = baseUrl.appendingPathComponent("timetable/groups")
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
