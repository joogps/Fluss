//
//  FlussWidgetProvider.swift
//  FlussWidgetExtension
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

import WidgetKit

struct FlussWidgetEntry: TimelineEntry {
    let date: Date
    let data: ParsedReadingData
}

struct FlussWidgetProvider: IntentTimelineProvider {
    private let entryCache = EntryCache()
    
    class EntryCache {
        var previousEntry: FlussWidgetEntry?
    }
    
    func placeholder(in context: Context) -> FlussWidgetEntry {
        FlussWidgetEntry(date: Date(), data: ParsedReadingData.sample)
    }
    
    func getSnapshot(for configuration: SelectRegionIntent, in context: Context, completion: @escaping (FlussWidgetEntry) -> ()) {
        Task {
            let data = await API.fetch(region: configuration.region)
            let entry = FlussWidgetEntry(date: .now, data: data)
            
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: SelectRegionIntent, in context: Context, completion: @escaping (Timeline<FlussWidgetEntry>) -> ()) {
        Task {
            let data = await API.fetch(region: configuration.region)
            
            let entry = FlussWidgetEntry(date: .now, data: data)
            var nextUpdate: Date?
            let calendar = Calendar.current
            
            if let currentReading = data.currentReading {
                let date = currentReading.date
                
                if calendar.component(.hour, from: date) >= calendar.component(.hour, from: .now) {
                    var components = DateComponents()
                    components.hour = 1
                    components.minute = 3
                    nextUpdate = calendar.date(byAdding: components, to: date)
                }
            }
            
            if nextUpdate == nil {
                var components = DateComponents()
                components.minute = 3
                nextUpdate = calendar.date(byAdding: components, to: .now)
            }
            
            if let nextUpdate {
                let timeline: Timeline<FlussWidgetEntry>
                
                if entry.data.alert == .failure, let previousEntry = entryCache.previousEntry {
                    timeline = Timeline(
                        entries: [previousEntry],
                        policy: .after(nextUpdate)
                    )
                } else {
                    timeline = Timeline(
                        entries: [entry],
                        policy: .after(nextUpdate)
                    )
                    entryCache.previousEntry = entry
                }
                
                completion(timeline)
            }
        }
    }
}
