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
            VStack(alignment: .leading) {
                Text(entry.code)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(entry.begin.formatted(date: .omitted, time: .shortened) + " - " + entry.end.formatted(date: .omitted, time: .shortened))
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text((entry.name))
                    .font(.system(size: 12))
                    .italic()
                Text((entry.type))
                    .font(.system(size: 12))
                    .italic()
                if let tutor = entry.tutor {
                    Text(tutor)
                        .font(.system(size: 12))
                        .italic()
                }
            }
        }
    }
}

struct EntryPreviewRow_Previews: PreviewProvider {
    static var previews: some View {
        let p = try! JSONDecoder().decode(ScheduleEntry.self, from: "{\"begin\":\"2022-03-07T15:45:00.000Z\",\"end\":\"2022-03-07T17:15:00.000Z\",\"dateString\":\"2022-03-07\",\"type\":\"Ćwiczenia\",\"code\":\"PJC\",\"name\":\"Programowanie w językach C i C++\",\"room\":\"A/357\",\"tutor\":null,\"groups\":[{\"location\":\"W\",\"mainSubject\":\"I\",\"studyMode\":\"s\",\"level\":\"I\",\"semester\":2,\"itn\":false,\"groupNumber\":46,\"groupLetter\":\"c\",\"raw\":\"WIs I.2 - 46c\"}],\"building\":\"A2020\"}".data(using: .utf8)!)
        return List {
            EntryPreviewRow(entry: p)
        }
    }
}
