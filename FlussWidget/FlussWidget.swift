//
//  FlussWidget.swift
//  FlussWidget
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import WidgetKit
import SwiftUI
import Charts

class EntryCache {
    var previousEntry: SimpleEntry?
}

struct Provider: IntentTimelineProvider {
    private let entryCache = EntryCache()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), leitura: BlumenauDataSource.sample)
    }

    func getSnapshot(for configuration: SelectRegionIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let leitura = await API.fetch(region: configuration.region)
            let entry = SimpleEntry(date: .now, leitura: leitura)
            
            completion(entry)
        }
    }

    func getTimeline(for configuration: SelectRegionIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        Task {
            let leitura = await API.fetch(region: configuration.region)
            
            let entry = SimpleEntry(date: .now, leitura: leitura)
            var nextUpdate: Date?
            let calendar = Calendar.current
            
            if let currentReading = leitura.currentReading {
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
                let timeline: Timeline<SimpleEntry>
                
                if entry.leitura.alert == .failure, let previousEntry = entryCache.previousEntry {
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

struct SimpleEntry: TimelineEntry {
    let date: Date
    let leitura: any DataSource
}

struct FlussWidgetEntryView<D: DataSource>: View {
    var leitura: D
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var readings: [D.R] {
        if widgetFamily == .systemSmall {
            return Array(leitura.sortedReadings.suffix(3))
        } else {
            return leitura.sortedReadings
        }
    }
    
    var sortedByLevel: [D.R] {
        readings.sorted { $0.level > $1.level }
    }
    
    var min: Double {
        floor(sortedByLevel.last?.level ?? 0)
    }
    
    var max: Double {
        ceil(sortedByLevel.first?.level ?? 0)
    }
    
    var color: Color {
        leitura.alert.color()
    }
    
    var updatedTime: String? {
        if let date = readings.last?.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.locale = .init(identifier: "pt_BR")
            
            return formatter.string(from: date)
        }
        return nil
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 6) {
                    Image(systemName: leitura.alert.symbol())
                        .foregroundStyle(.secondary)
                    
                    Text(leitura.alert.text())
                        .kerning(-0.4)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    
                    if widgetFamily != .systemSmall {
                        Text(leitura.name)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(Color(white: 0.03))
                            .padding(2)
                            .padding(.horizontal, 10)
                            .background {
                                Capsule()
                                    .fill(Color(white: 0.75))
                            }
                            .compositingGroup()
                            .blendMode(.luminosity)
                    }
                }
                .font(.body.weight(.bold))
                .foregroundStyle(color)
                
                Chart {
                    ForEach(readings) { nivel in
                        AreaMark(x: .value("Time", nivel.date),
                                 yStart: .value("Height", nivel.level),
                                 yEnd: .value("Height", min))
                        .foregroundStyle(.linearGradient(.init(colors: [color, .clear]), startPoint: .top, endPoint: .bottom))
                        .opacity(0.5)
                        
                        LineMark(
                            x: .value("Time", nivel.date),
                            y: .value("Height", nivel.level)
                        )
                        .foregroundStyle(color)
                    }
                }
                .chartYScale(domain: [min, max])
                .chartLegend(.hidden)
                .chartYAxis {
                    AxisMarks(preset: .aligned, position: .leading, values: .automatic(desiredCount: 2)) { value in
                        AxisValueLabel(String(value.as(Int.self) ?? 0)+"m")
                            .foregroundStyle(.white)
                            .font(.caption2.bold().monospaced())
                    }
                    
                    AxisMarks(values: .automatic(desiredCount: 3)) {
                        AxisGridLine()
                            .foregroundStyle(.tertiary)
                    }
                }
                .chartXAxis {
                    
                }
                .padding(.vertical, 2)
                
                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading) {
                        Text(String(format: "%.2f", readings.last?.level ?? 0)+"m")
                            .kerning(-1.2)
                            .font(.largeTitle.bold())
                            .allowsTightening(true)
                            .minimumScaleFactor(0.5)
                            .blendMode(.luminosity)
                        
                    }
                    
                    if widgetFamily != .systemSmall {
                        TimelineView(.everyMinute) { _ in
                            if let updatedTime {
                                Text("atualizado\n\(updatedTime)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        if widgetFamily != .systemSmall {
                            Text(String(Int(round(leitura.delta*100)))+"cm")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        
                        Image(systemName: leitura.delta > 0 ? "chevron.up" : "chevron.down")
                            .font(.title2.bold())
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }
}

struct FlussSmallWidgetView: View {
    var systemImage: String
    var title: String
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.title3.bold())
                .padding(.vertical, 2)
                .frame(width: 20, height: 20)
            
            Text(title)
                .foregroundStyle(.secondary)
                .font(.headline.bold())
                .minimumScaleFactor(0.5)
        }
    }
}

struct FlussWidget: Widget {
    let kind: String = "FlussWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: Provider()) { entry in
            let background = entry.leitura.alert.color()
                .overlay(Color(white: 0.03).blendMode(.luminosity))
            
            if #available(macOS 14.0, iOS 17.0, *) {
                widgetView(for: entry.leitura)
                    .containerBackground(for: .widget) {
                        background
                    }
            } else {
                widgetView(for: entry.leitura)
                    .padding()
                    .background(background)
            }
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Situação da enchente")
        .description("Monitore as variações do nível da água ao longo das últimas horas.")
    }
    
    @ViewBuilder
    func widgetView(for source: any DataSource) -> some View {
        if let data = source as? BlumenauDataSource {
            FlussWidgetEntryView(leitura: data)
        } else if let data = source as? PortoAlegreDataSource {
            FlussWidgetEntryView(leitura: data)
        }
    }
}

#if os(iOS)
@available(iOS 16.1, *)
struct FlussWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LeituraAttributes.self) { context in
            FlussWidgetEntryView(leitura: context.state.leitura)
                .padding()
                .background {
                    context.state.leitura.alert.color()
                        .overlay(Color(white: 0.03).blendMode(.luminosity))
                }
        } dynamicIsland: { context in
            let leitura = context.state.leitura
            
            return DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.center, content: {
                    FlussWidgetEntryView(leitura: leitura)
                })
            }, compactLeading: {
                Image(systemName: leitura.alert.symbol())
                    .foregroundStyle(leitura.alert.color())
            }, compactTrailing: {
                if let nivel = leitura.currentReading {
                    Text(String(format: "%.2f", nivel.level)+"m")
                        .foregroundStyle(leitura.alert.color())
                        .bold()
                }
            }, minimal: {
                if let nivel = leitura.currentReading {
                    Text(String(format: "%.2f", nivel.level)+"m")
                        .foregroundStyle(leitura.alert.color())
                        .bold()
                }
            })
        }
    }
}

struct FlussSmallWidget: Widget {
    let kind: String = "FlussSmallWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: Provider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                content(entry: entry)
                    .containerBackground(.tertiary, for: .widget)
            } else {
                content(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.accessoryCircular, .accessoryInline])
        .configurationDisplayName("Nível da água")
        .description("Monitore o nível da água.")
    }
    
    func content(entry: SimpleEntry) -> some View {
        if entry.leitura.alert == .failure {
            FlussSmallWidgetView(systemImage: entry.leitura.alert.symbol(),
                                 title: "")
        } else {
            FlussSmallWidgetView(systemImage: entry.leitura.alert.symbol(),
                                 title: String(entry.leitura.currentReading?.level ?? 0)+"m")
        }
    }
}

struct FlussSmallWidget2: Widget {
    let kind: String = "FlussSmallWidget2"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: Provider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                content(entry: entry)
                    .containerBackground(.tertiary, for: .widget)
            } else {
                content(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.accessoryCircular, .accessoryInline])
        .configurationDisplayName("Variação da água")
        .description("Monitore a variação do nível da água.")
    }
    
    func content(entry: SimpleEntry) -> some View {
        if entry.leitura.alert == .failure {
            FlussSmallWidgetView(systemImage: entry.leitura.alert.symbol(),
                                 title: "")
        } else {
            FlussSmallWidgetView(systemImage: entry.leitura.delta > 0 ? "chevron.up" : "chevron.down",
                                 title: String(Int(round(entry.leitura.delta*100)))+"cm")
        }
    }
}
#endif
