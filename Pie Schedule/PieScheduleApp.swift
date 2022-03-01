//
//  PieScheduleApp.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift
import SwiftUI

@main
struct PieScheduleApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.realmConfiguration, .prodConfig)
        }
    }
}
