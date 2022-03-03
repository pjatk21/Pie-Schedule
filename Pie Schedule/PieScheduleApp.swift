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
                .environment(\.altapi, .init())
        }
    }
}

// MARK: - Altapi enviroment extension
private struct AltapiEnvironmentKey: EnvironmentKey {
    static let defaultValue = AltapiManager()
}
extension EnvironmentValues {
    var altapi: AltapiManager {
        get { self[AltapiEnvironmentKey.self] }
        set { self[AltapiEnvironmentKey.self] = newValue }
    }
}
