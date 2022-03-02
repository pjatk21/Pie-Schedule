//
//  BackgroundFetch.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 02/03/2022.
//

import Foundation
import BackgroundTasks
import os.log

// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"prov.kpostek.pieschedule.fetch"]

struct BackgroundTasks {
    internal static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BackgroundTasks")
    static let refreshTaskId = "prov.kpostek.pieschedule.fetch"
    
    static func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        logger.info("Scheduling task...")
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("Requested background refresh!")
        } catch {
            logger.warning("Couldn't submit request \(error.localizedDescription)")
        }
    }
    
    static func handleRefresh(refreshTask: BGAppRefreshTask?) {
        print("Test1")
        Task {
            guard let task = refreshTask else {
                return
            }
            logger.info("Starting \(task.identifier)")
            
            logger.info("Boobs1")
            do {
                let k = try await AltapiManager.backgroundMode.getAvailableGroups()
                logger.info("Booba \(k.groupsAvailable.count)")
            } catch {
                logger.error("(BG) Error while fetching: \(error.localizedDescription)")
            }
        }
    }
}
