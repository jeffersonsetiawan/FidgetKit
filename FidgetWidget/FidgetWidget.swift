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
        FidgetEntry(date: Date(), fidgets: [.batman])
    }

    func getSnapshot(in context: Context, completion: @escaping (FidgetEntry) -> ()) {
        let entry = FidgetEntry(date: Date(), fidgets: [.batman])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FidgetEntry>) -> ()) {
        guard let data = UserDefaults(suiteName: appGroup)?.value(forKey: "fidgets") as? Data,
              let fidgets = try? JSONDecoder().decode([Fidget].self, from: data) else {
            completion(Timeline(entries: [], policy: .never))
            return
        }
        
        guard let fidgetThatWouldStop = getEarliestFidgetThatWillStopSpinning(from: fidgets) else {
            completion(Timeline(entries: [FidgetEntry(date: Date(), fidgets: fidgets)], policy: .never))
            return
        }

//        let dateToBeRefresh = Date()
        let dateToBeRefresh = Calendar.current.date(byAdding: .second, value: Int(fidgetThatWouldStop.timeNeededToFinishRotation), to: Date())!
//        let dateToBeRefresh = Date(timeIntervalSinceNow: fidgetThatWouldStop.timeNeededToFinishRotation)
        let timeline = Timeline(
            entries: [
                FidgetEntry(date: Date(), fidgets: fidgets),
                FidgetEntry(date: Date(timeIntervalSinceNow: 10), fidgets: [fidgets[0]])
            ],
            policy: .after(dateToBeRefresh)
        )
        completion(timeline)
    }
    
    private func getEarliestFidgetThatWillStopSpinning(from fidgets: [Fidget]) -> Fidget? {
        return fidgets.filter(\.isInRotating)
            .sorted(by: \.timeNeededToFinishRotation, <)
            .first
    }
}

struct FidgetEntry: TimelineEntry {
    let date: Date
    let fidgets: [Fidget]
}

struct FidgetWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            ForEach(entry.fidgets, id: \.self) { fidget in
                Link(destination: fidget.fidgetUrl) {
                    HStack {
                        Image(fidget.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        VStack {
                            Text(fidget.name)
                            if fidget.isInRotating {
                                Text("Spinning!")
                            } else  {
                                Text("Not Spinning!")
                            }
                            Text(entry.date, style: .relative)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}


struct FidgetWidget: Widget {
    let kind: String = "FidgetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FidgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fidget")
        .description("Put your fav Fidget into your home screen!")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct FidgetBundle: WidgetBundle {
    var body: some Widget {
        FidgetWidget()
        FidgetSmallWidget()
    }
}

struct FidgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        FidgetWidgetEntryView(entry: FidgetEntry(date: Date(), fidgets: [.batman]))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

