//
//  EntryPreviewRow.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 22/02/2022.
//

import SwiftUI
import RealmSwift
import SwiftDate

struct EntryPreviewRow: View {
    @State var entry: ScheduleEntry
    
    var body: some View {
        HStack {
            if (entry.isItRightNow()){
                Rectangle()
                    .foregroundColor(.red)
                    .frame(maxWidth: 2, maxHeight: .infinity)
                    .opacity(0.6)
            }
            VStack(alignment: .leading) {
                Text(entry.code)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text((entry.begin..<entry.end).formatted())
            }
            Spacer(minLength: 30)
            VStack(alignment: .trailing) {
                Text((entry.name))
                    .font(.system(size: 12))
                    .italic()
                    .multilineTextAlignment(.trailing)
                Text((entry.type))
                    .font(.system(size: 12))
                    .italic()
                    .multilineTextAlignment(.trailing)
                if let tutor = entry.tutor {
                    Text(tutor)
                        .font(.system(size: 12))
                        .italic()
                }
            }
        }
        .opacity(entry.end <= .now ? 0.3 : 1)
    }
}


struct EntryPreviewRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            EntryPreviewRow(entry: .loremIpsum)
        }
    }
}

