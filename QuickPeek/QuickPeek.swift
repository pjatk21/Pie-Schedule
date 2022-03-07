//
//  QuickPeek.swift
//  QuickPeek
//
//  Created by Krystian Postek on 01/03/2022.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift
import SwiftDate

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> QuickPeekEntry {
        QuickPeekEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (QuickPeekEntry) -> ()) {
        let entry = QuickPeekEntry(date: Date(), configuration: configuration, data: ScheduleEntry.loremIpsum, mode: .beforeClasses)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let realm = try! Realm(configuration: .prodConfig)
        let dataEntries = realm.objects(ScheduleEntry.self).where {
            $0.end > .now && $0.begin <= Date() + (configuration.vacationMinLength?.intValue.days ?? 3.days)
        }
        
        var entries: [QuickPeekEntry] = dataEntries.sorted(by: \.begin).map { entry in
            let mode: QuickPeekMode = entry.isItRightNow() ? .inClass : .beforeClasses
            return QuickPeekEntry(date: entry.begin, configuration: configuration, data: entry, mode: mode)
        }
        
        if entries.count == 0 {
            // enable vacation mode
            let nextActivity = realm.objects(ScheduleEntry.self).where {
                $0.begin >= Date()
            }.sorted {
                $0.begin < $1.begin
            }.first
            entries.append(QuickPeekEntry(date: .now, configuration: configuration, data: nextActivity, mode: .vacation))
        }

        //let timeline = Timeline(entries: entries, policy: .after(entries.last?.data?.end ?? .now + 90.seconds))
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

enum QuickPeekMode: String {
    case beforeClasses, inClass, vacation, placeholder
}

struct QuickPeekEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var data: ScheduleEntry? = nil
    var mode: QuickPeekMode = .placeholder
    
    var timeLeftToEnd: String? {
        guard let entry = data else {
            return nil
        }
        
        guard mode == .inClass else {
            return nil
        }
        
        return (Date.now..<entry.end).formatted(.components(style: .abbreviated, fields: [.minute, .hour]))
    }
    
    var timeLeftVacations: String? {
        guard let entry = data else {
            return nil
        }
        
        guard mode == .vacation else {
            return nil
        }
        
        return (Date.now..<entry.begin).formatted(.components(style: .wide, fields: [.month, .week, .day]))
    }
}

struct QuickPeekEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    private func daysLeft(_ scheduleEntry: ScheduleEntry) -> Int {
        (scheduleEntry.begin - Date()).day ?? -1
    }

    var body: some View {
        if let remaining = entry.timeLeftToEnd {
            VStack(alignment: .leading) {
                Text("Remaining time:")
                    .font(.system(size: 14))
                Text(remaining)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            .padding()
        } else if let vacationTime = entry.timeLeftVacations {
            VStack(alignment: .leading) {
                Text("No classes on the horizon 😎")
                    .font(.system(size: 14))
                    .italic()
                    .opacity(0.8)
                Spacer()
                    .frame(height: 20.0)
                Text("\(vacationTime) left")
                Text(entry.data!.begin.formatted(date: .abbreviated, time: .omitted))
            }
            .padding()
        } else if let scheduleEntry = entry.data {
            VStack(alignment: .leading) {
                Text("Next:")
                    .font(.system(size: 14))
                Text(scheduleEntry.code)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text(scheduleEntry.begin.formatted())
                    .font(.system(size: 12))
                Text(scheduleEntry.room)
                    .font(.system(size: 12))
            }
            .padding()
        } else {
            PlaceholerView()
        }
        
        if entry.configuration.develStamp == 1 {
            Text("\(entry.mode.rawValue) \(Date.now.formatted())")
                .font(.system(size: 5, design: .monospaced))
            if let data = entry.data {
                Text("rn: \(data.isItRightNow().description) future: \(data.end.isInFuture.description)")
                    .font(.system(size: 5, design: .monospaced))
            }
        }
    }
}

struct PlaceholerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("🤔")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .opacity(0.2)
        }
        .padding()
    }
}

@main
struct QuickPeek: Widget {
    let kind: String = "QuickPeek"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuickPeekEntryView(entry: entry)
        }
        .configurationDisplayName("Quick peek")
        .description("Quick peek on your schedule.")
        .supportedFamilies([.systemSmall])
    }
}

struct QuickPeek_Previews: PreviewProvider {
    static var previews: some View {
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent(), data: ScheduleEntry.loremIpsum, mode: .beforeClasses))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent(), data: ScheduleEntry.loremIpsum, mode: .inClass))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent(), data: { let x = ScheduleEntry.loremIpsum; x.begin = x.begin + 15.days; return x }(), mode: .vacation))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
