//
//  FlussWidget.swift
//  FlussWidget
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import WidgetKit
import SwiftUI
import Charts

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), leitura: Leitura.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let leitura = await API.fetchLeituras()
            let entry = SimpleEntry(date: .now, leitura: leitura)
            
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let leitura = await API.fetchLeituras()
            let entry = SimpleEntry(date: .now, leitura: leitura)
            
            var nextUpdate: Date?
            let calendar = Calendar.current
            
            if let nivelAtual = leitura.nivelAtual {
                let date = nivelAtual.dataLeitura
                
                if calendar.component(.hour, from: date) >= calendar.component(.hour, from: .now) {
                    var components = DateComponents()
                    components.hour = 1
                    components.minute = 5
                    nextUpdate = calendar.date(byAdding: components, to: date)
                }
            }
            
            if nextUpdate != nil {
                var components = DateComponents()
                components.minute = 5
                nextUpdate = calendar.date(byAdding: components, to: .now)
            }
            
            if let nextUpdate {
                let timeline = Timeline(
                    entries: [entry],
                    policy: .after(nextUpdate)
                )
                
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let leitura: Leitura
}

struct FlussWidgetEntryView : View {
    var leitura: Leitura
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var niveis: [LeituraNivel] {
        if widgetFamily == .systemSmall {
            return Array(leitura.sortedNiveis.suffix(3))
        } else {
            return leitura.sortedNiveis
        }
    }
    
    var sortedByLevel: [LeituraNivel] {
        niveis.sorted { $0.nivel > $1.nivel }
    }
    
    var min: Double {
        floor(sortedByLevel.last?.nivel ?? 0)
    }
    
    var max: Double {
        ceil(sortedByLevel.first?.nivel ?? 0)
    }
    
    var color: Color {
        leitura.alerta.color()
    }
    
    var updatedTime: String? {
        if var date = niveis.last?.dataLeitura {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            formatter.locale = .init(identifier: "pt_BR")
            
            date.addTimeInterval(-60*60*3)
            
            return formatter.string(from: date)
        }
        return nil
    }

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 6) {
                    Image(systemName: leitura.alerta.symbol())
                        .foregroundStyle(.secondary)
                    
                    Text(leitura.alerta.text())
                        .kerning(-0.4)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    
                    if widgetFamily != .systemSmall {
                        Text(leitura.cidade)
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
                    ForEach(niveis) { nivel in
                        AreaMark(x: .value("Time", nivel.dataLeitura),
                                 yStart: .value("Height", nivel.nivel),
                                 yEnd: .value("Height", min))
                        .foregroundStyle(.linearGradient(.init(colors: [color, .clear]), startPoint: .top, endPoint: .bottom))
                        .opacity(0.5)
                        
                        LineMark(
                            x: .value("Time", nivel.dataLeitura),
                            y: .value("Height", nivel.nivel)
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
                        Text(String(niveis.last?.nivel ?? 0)+"m")
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
                            Text(String(Int(round(leitura.variacao*100)))+"cm")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        
                        Image(systemName: leitura.variacao > 0 ? "chevron.up" : "chevron.down")
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            let background = entry.leitura.alerta.color()
                .overlay(Color(white: 0.03).blendMode(.luminosity))
            
            if #available(macOS 14.0, iOS 17.0, *) {
                FlussWidgetEntryView(leitura: entry.leitura)
                    .containerBackground(for: .widget) {
                        background
                    }
            } else {
                FlussWidgetEntryView(leitura: entry.leitura)
                    .padding()
                    .background(background)
            }
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Situação do rio")
        .description("Monitore a alteração do nível do rio ao longo das últimas horas.")
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
                    context.state.leitura.alerta.color()
                        .overlay(Color(white: 0.03).blendMode(.luminosity))
                }
        } dynamicIsland: { context in
            let leitura = context.state.leitura
            
            return DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.center, content: {
                    FlussWidgetEntryView(leitura: leitura)
                })
            }, compactLeading: {
                Image(systemName: leitura.alerta.symbol())
                    .foregroundStyle(leitura.alerta.color())
            }, compactTrailing: {
                if let nivel = leitura.nivelAtual {
                    Text(String(nivel.nivel)+"m")
                        .foregroundStyle(leitura.alerta.color())
                        .bold()
                }
            }, minimal: {
                if let nivel = leitura.nivelAtual {
                    Text(String(nivel.nivel)+"m")
                        .foregroundStyle(leitura.alerta.color())
                        .bold()
                }
            })
        }
    }
}

struct FlussSmallWidget: Widget {
    let kind: String = "FlussSmallWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
        .configurationDisplayName("Nível do rio")
        .description("Monitore o nível do rio.")
    }
    
    func content(entry: SimpleEntry) -> some View {
        FlussSmallWidgetView(systemImage: entry.leitura.alerta.symbol(), title: String(entry.leitura.nivelAtual?.nivel ?? 0)+"m")
    }
}

struct FlussSmallWidget2: Widget {
    let kind: String = "FlussSmallWidget2"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
        .configurationDisplayName("Variação do rio")
        .description("Monitore a variação do nível do rio.")
    }
    
    func content(entry: SimpleEntry) -> some View {
        FlussSmallWidgetView(systemImage: entry.leitura.variacao > 0 ? "chevron.up" : "chevron.down", title: String(Int(round(entry.leitura.variacao*100)))+"cm")
    }
}
#endif
