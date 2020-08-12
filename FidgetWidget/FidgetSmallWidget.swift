//
//  FidgetSmallWidget.swift
//  FidgetKit
//
//  Created by Jefferson Setiawan on 12/08/20.
//

import WidgetKit
import SwiftUI
import Intents

struct FidgetSmallWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SingleFidgetEntry {
        SingleFidgetEntry(date: Date(), fidget: .batman)
    }

    func getSnapshot(for configuration: FidgetSelectionIntent, in context: Context, completion: @escaping (SingleFidgetEntry) -> ()) {
        let entry = SingleFidgetEntry(date: Date(), fidget: .red)
        completion(entry)
    }

    func getTimeline(for configuration: FidgetSelectionIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let data = UserDefaults(suiteName: appGroup)?.value(forKey: "fidgets") as? Data,
              let fidgets = try? JSONDecoder().decode([Fidget].self, from: data) else {
            completion(Timeline(entries: [], policy: .never))
            return
        }
        
        let fidget = getFidget(from: fidgets, with: configuration)
        
        guard let fidgetThatWouldStop = getEarliestFidgetThatWillStopSpinning(from: fidgets) else {
            let timeline = Timeline(
                entries: [SingleFidgetEntry(date: Date(), fidget: fidget)],
                policy: .never)
            completion(timeline)
            return
        }
        let dateToBeRefresh = Date(timeIntervalSinceNow: fidgetThatWouldStop.timeNeededToFinishRotation)
        let timeline = Timeline(
            entries: [
                SingleFidgetEntry(date: Date(), fidget: fidget),
            ],
            policy: .after(dateToBeRefresh)
        )
        completion(timeline)
    }
    
    private func getFidget(from fidgets: [Fidget], with configuration: FidgetSelectionIntent) -> Fidget? {
        return fidgets.first { $0.id == configuration.fidget.rawValue }
    }
    
    private func getEarliestFidgetThatWillStopSpinning(from fidgets: [Fidget]) -> Fidget? {
        return fidgets.filter(\.isInRotating)
            .sorted(by: \.timeNeededToFinishRotation, <)
            .first
    }
}

struct SingleFidgetEntry: TimelineEntry {
    let date: Date
    let fidget: Fidget?
}

struct FidgetSmallWidgetEntryView : View {
    var entry: SingleFidgetEntry
    var body: some View {
        VStack {
            if let fidget = entry.fidget {
                VStack {
                    Image(fidget.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                    if fidget.isInRotating {
                        Text("Spinning!")
                    } else  {
                        Text("Not Spinning!")
                    }
                    Text(entry.date, style: .relative)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(ContainerRelativeShape().fill(Color.red))
            } else {
                Text("NOT FOUND!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ContainerRelativeShape().fill(Color.red))
            }
            
        }
        .frame(maxWidth: .infinity)
    }
}


struct FidgetSmallWidget: Widget {
    let kind: String = "FidgetSmallWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: FidgetSelectionIntent.self, provider: FidgetSmallWidgetProvider()) { entry in
            FidgetSmallWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Single Fidget")
        .description("Put your favorite Fidget into your home screen!")
        .supportedFamilies([.systemSmall])
    }
}

struct FidgetSmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        FidgetSmallWidgetEntryView(
            entry: SingleFidgetEntry(
                date: Date(),
                fidget: .batman
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

