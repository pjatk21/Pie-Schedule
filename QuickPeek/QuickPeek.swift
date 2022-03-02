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
        let entry = QuickPeekEntry(date: Date(), configuration: configuration, data: ScheduleEntry.loremIpsum)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let realm = try! Realm(configuration: .prodConfig)
        let dataEntries = realm.objects(ScheduleEntry.self).where {
            $0.begin >= Date() && $0.begin <= Date() + (configuration.vacationMinLength?.intValue.days ?? 3.days)
        }
        
        var entries: [QuickPeekEntry] = dataEntries.map { entry in
            QuickPeekEntry(date: entry.begin, configuration: configuration, data: entry)
        }.reversed()
        
        if entries.count == 0 {
            let nextActivity = realm.objects(ScheduleEntry.self).where {
                $0.begin >= Date()
            }.reversed().first
            entries.append(QuickPeekEntry(date: .now, configuration: configuration, data: nextActivity, noNearActivities: true))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct QuickPeekEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var data: ScheduleEntry? = nil
    var noNearActivities: Bool = false
}

struct QuickPeekEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    private func daysLeft(_ scheduleEntry: ScheduleEntry) -> Int {
        (scheduleEntry.begin - Date()).day ?? -1
    }

    var body: some View {
        if entry.noNearActivities {
            if let scheduleEntry = entry.data {
                VStack(alignment: .leading) {
                    Text("No classes on the horizon 😎")
                        .font(.system(size: 14))
                        .italic()
                        .opacity(0.8)
                    Spacer()
                        .frame(height: 20.0)
                    Text("\(daysLeft(scheduleEntry)) days until")
                    Text(scheduleEntry.begin.formatted(date: .abbreviated, time: .omitted))
                }
                .padding()
            }
        } else {
            if let scheduleEntry = entry.data {
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
        }
    }
}

struct PlaceholerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Next:")
                .font(.system(size: 12))
            Text("🤔")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .opacity(0.4)
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
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent(), data: ScheduleEntry.loremIpsum))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent(), data: { let x = ScheduleEntry.loremIpsum; x.begin = x.begin + 12.days; return x }(), noNearActivities: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: QuickPeekEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
