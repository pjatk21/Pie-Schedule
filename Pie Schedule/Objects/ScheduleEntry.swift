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
    
    func isItRightNow(_ when: Date = .now) -> Bool {
        when >= begin && when < end
    }
    
    private enum CodingKeys: String, CodingKey {
        case begin, end, code, type, name, room, tutor, groups
    }
    
    static let loremIpsum: ScheduleEntry = {
        let loremEntry = ScheduleEntry()
        loremEntry.begin = Date() - 16.minutes
        loremEntry.end = loremEntry.begin + 90.minutes
        loremEntry.name = "Tworzenie interfejsów w SwiftUI"
        loremEntry.code = "TIS"
        loremEntry.type = "Ćwiczenia"
        loremEntry.tutor = "Krystian Postek" // I wish
        loremEntry.room = "A/357"
        loremEntry.groups.append("WIs I.2 - 46c")
        return loremEntry
    }()
}
