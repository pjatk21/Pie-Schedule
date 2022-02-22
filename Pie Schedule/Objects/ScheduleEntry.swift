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
    // @Persisted(primaryKey: true) var _id: ObjectId = ObjectId()
    @Persisted var begin: String
    @Persisted var end: String
    @Persisted var dateString: String
    @Persisted var code: String?
    @Persisted var type: String?
    @Persisted var name: String?
    @Persisted var room: String?
    @Persisted var tutor: String?
    @Persisted var groups: RealmSwift.List<ScheduleGroup>
    
    var id: String {
        UUID().uuidString
    }
    
    var beginDate: Date {
        begin.toISODate(region: .local)!.date
    }
    
    /* private enum CodingKeys: String, CodingKey {
        case begin, end, dateString, code, name, room, tutor
    } */
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
            let r = try JSONDecoder().decode(ScheduleEntryResponse.self, from: "{\"entries\":[{\"begin\":\"2022-03-07T15:45:00.000Z\",\"end\":\"2022-03-07T17:15:00.000Z\",\"dateString\":\"2022-03-07\",\"type\":\"Ćwiczenia\",\"code\":\"PJC\",\"name\":\"Programowanie w językach C i C++\",\"room\":\"A/357\",\"tutor\":null,\"groups\":[{\"location\":\"W\",\"mainSubject\":\"I\",\"studyMode\":\"s\",\"level\":\"I\",\"semester\":2,\"itn\":false,\"groupNumber\":46,\"groupLetter\":\"c\",\"raw\":\"WIs I.2 - 46c\"}],\"building\":\"A2020\"},{\"begin\":\"2022-03-07T17:30:00.000Z\",\"end\":\"2022-03-07T19:00:00.000Z\",\"dateString\":\"2022-03-07\",\"type\":\"Ćwiczenia\",\"code\":\"GUI\",\"name\":\"Programowanie obiektowe i GUI\",\"room\":\"A/261\",\"tutor\":null,\"groups\":[{\"location\":\"W\",\"mainSubject\":\"I\",\"studyMode\":\"s\",\"level\":\"I\",\"semester\":2,\"itn\":false,\"groupNumber\":46,\"groupLetter\":\"c\",\"raw\":\"WIs I.2 - 46c\"}],\"building\":\"A2020\"},{\"begin\":\"2022-03-07T19:15:00.000Z\",\"end\":\"2022-03-07T20:45:00.000Z\",\"dateString\":\"2022-03-07\",\"type\":\"Ćwiczenia\",\"code\":\"MAD\",\"name\":\"Matematyka dyskretna\",\"room\":\"B/109\",\"tutor\":null,\"groups\":[{\"location\":\"W\",\"mainSubject\":\"I\",\"studyMode\":\"s\",\"level\":\"I\",\"semester\":2,\"itn\":false,\"groupNumber\":46,\"groupLetter\":\"c\",\"raw\":\"WIs I.2 - 46c\"}],\"building\":\"B2020\"}]}".data(using: .utf8)!)
            try! realm.write {
                realm.deleteAll()
                realm.add(r.entries)
            }
        } catch {
            return
        }
    }
}
