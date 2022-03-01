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
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, data: ScheduleEntry.loremIpsum)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let realm = try! Realm(configuration: .prodConfig)
        let dataEntries = realm.objects(ScheduleEntry.self).where {
            $0.begin >= Date() && $0.begin <= Date() + 3.days
        }
        
        let entries: [SimpleEntry] = dataEntries.map { entry in
            SimpleEntry(date: entry.begin, configuration: configuration, data: entry)
        }.reversed()

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var data: ScheduleEntry? = nil
    var dayOver: Bool = false
}

struct QuickPeekEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    var body: some View {
        if let scheduleEntry = entry.data {
            VStack(alignment: .leading) {
                Text("Next:")
                    .font(.system(size: 14))
                Text(scheduleEntry.code)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(scheduleEntry.begin.formatted())
                    .font(.system(size: 12))
                Text(scheduleEntry.room)
                    .font(.system(size: 12))
            }
            .padding()
        } else if entry.dayOver {
            
        } else {
            PlaceholerView()
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
        QuickPeekEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), data: ScheduleEntry.loremIpsum))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        QuickPeekEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
