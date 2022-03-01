//
//  RealmConfiguration.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 01/03/2022.
//

import RealmSwift
import Foundation

extension Realm.Configuration {
    static let previewConfig: Realm.Configuration = .init(inMemoryIdentifier: "preview")
    static let devConfig: Realm.Configuration = .init(deleteRealmIfMigrationNeeded: true)
    static let prodConfig: Realm.Configuration = {
        var realmLocation = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.prov.kpostek.pieschedule")!
        realmLocation.appendPathComponent("pieschedule.realm")
        return Realm.Configuration(fileURL: realmLocation, deleteRealmIfMigrationNeeded: true)
    }()
}
