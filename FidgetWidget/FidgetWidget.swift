//
//  FidgetWidget.swift
//  FidgetWidget
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FidgetEntry {
        FidgetEntry(date: Date(), fidget: .batman)
    }

    func getSnapshot(in context: Context, completion: @escaping (FidgetEntry) -> ()) {
        let entry = FidgetEntry(date: Date(), fidget: .batman)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [FidgetEntry] = []
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = FidgetEntry(date: entryDate, fidget: .batman)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct FidgetEntry: TimelineEntry {
    let date: Date
    let fidget: Fidget
}

struct FidgetWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
            .widgetURL(entry.fidget.fidgetUrl)
    }
}

@main
struct FidgetWidget: Widget {
    let kind: String = "FidgetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FidgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fidget")
        .description("Put your fav Fidget into your home screen!")
    }
}

struct FidgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        FidgetWidgetEntryView(entry: FidgetEntry(date: Date(), fidget: .batman))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
