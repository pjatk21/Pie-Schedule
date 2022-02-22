//
//  ScheduleGroup.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift

class ScheduleGroup: Object, Codable, Identifiable {
    @Persisted var raw: String
    
    var id: String {
        raw
    }
}

extension ScheduleGroup {
    static func preloadPreview() {
        do {
            let realm = try Realm(configuration: .init(deleteRealmIfMigrationNeeded: true))
            // clear groups
            let groups = realm.objects(ScheduleGroup.self)
            let a = ScheduleGroup()
            a.raw = "WIs I.2 - 46c"
            let b = ScheduleGroup()
            b.raw = "WIs I.2 - 1w"
            try! realm.write {
                realm.delete(groups)
                realm.add(a)
                realm.add(b)
            }
        } catch {
            return
        }
    }
}
