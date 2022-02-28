//
//  ScheduleEntry.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import Foundation
import RealmSwift
import SwiftDate

class ScheduleEntry: Object, Codable, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var begin: Date
    @Persisted var end: Date
    @Persisted var code: String
    @Persisted var type: String
    @Persisted var name: String
    @Persisted var room: String
    @Persisted var tutor: String?
    @Persisted var groups: RealmSwift.List<String>
    
    var id: String {
        _id.stringValue
    }
    
    private enum CodingKeys: String, CodingKey {
        case begin, end, code, type, name, room, tutor, groups
    }
}

extension ScheduleEntry {
    static var previewsPopulated: Bool {
        do {
            let realm = try Realm(configuration: .init(deleteRealmIfMigrationNeeded: true))
            let entries = realm.objects(ScheduleEntry.self)
            return entries.count > 0
        } catch {
            return false
        }
    }
    
    static func preloadPreview() {
        do {
            let realm = try Realm(configuration: .init(deleteRealmIfMigrationNeeded: true))
            let r = try JSONDecoder().decode(ScheduleEntryResponse.self, from: "{\"entries\":[]}".data(using: .utf8)!)
            try! realm.write {
                realm.deleteAll()
                realm.add(r.entries)
            }
        } catch {
            return
        }
    }
}
