//
//  ScheduleGroup.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift

class ScheduleGroup: Object, Codable, Identifiable {
    @Persisted var name: String
    @Persisted var assingned = false
    
    var id: String {
        name
    }
}

extension ScheduleGroup {
    static func preloadPreview() {
        do {
            let realm = try Realm(configuration: .init(deleteRealmIfMigrationNeeded: true))
            // clear groups
            let groups = realm.objects(ScheduleGroup.self)
            let a = ScheduleGroup()
            a.name = "WIs I.2 - 46c"
            let b = ScheduleGroup()
            b.name = "WIs I.2 - 1w"
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
