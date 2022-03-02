//
//  PieScheduleApp.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 21/02/2022.
//

import RealmSwift
import SwiftUI
import UIKit
import BackgroundTasks

@main
struct PieScheduleApp: SwiftUI.App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.realmConfiguration, .prodConfig)
                .onChange(of: scenePhase, perform: onScenePhaseChange)
        }
    }
    
    private func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            BackgroundTasks.scheduleRefresh()
        default:
            break
        }
    }
}


final class AppDelegate: UIResponder, UIApplicationDelegate  {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTasks.refreshTaskId, using: nil) { task in
            // BackgroundTasks.scheduleRefresh()
            print(task)
            BackgroundTasks.handleRefresh(refreshTask: task as? BGAppRefreshTask)
        }
    }
}

