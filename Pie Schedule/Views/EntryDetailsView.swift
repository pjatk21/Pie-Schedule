//
//  EntryDetailsView.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 01/03/2022.
//

import SwiftUI

struct EntryDetailsView: View {
    @State var scheduleEntry: ScheduleEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text("\(scheduleEntry)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
            }
            Spacer()
        }
    }
}

struct EntryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EntryDetailsView(scheduleEntry: ScheduleEntry.loremIpsum)
    }
}
