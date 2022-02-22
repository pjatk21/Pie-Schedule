//
//  EntriesList.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 22/02/2022.
//

import SwiftUI
import RealmSwift

struct EntriesList: View {
    @State var entries: Results<ScheduleEntry>
    
    var body: some View {
        List(entries) { entry in
            EntryPreviewRow(entry: entry)
        }
    }
}
