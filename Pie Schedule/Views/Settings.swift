//
//  Settings.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 22/02/2022.
//

import SwiftUI
import RealmSwift

struct Settings: View {
    @ObservedResults(ScheduleGroup.self) var groups
    
    var body: some View {
        Form {
            Section(header: Text("Grupy")) {
                List(groups) {
                    Text($0.raw)
                }
            }
        }
        .navigationTitle("Ustawienia")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleGroup.preloadPreview()
        return Settings()
    }
}
