//
//  FlussWidgetView.swift
//  FlussWidgetExtension
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

import SwiftUI
import Charts
import WidgetKit

struct FlussWidgetView: View {
    var data: ParsedReadingData
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var readings: [ParsedReading] {
        if widgetFamily == .systemSmall {
            return Array(data.sortedReadings.suffix(3))
        } else {
            return data.sortedReadings
        }
    }
    
    var sortedByLevel: [ParsedReading] {
        readings.sorted { $0.level > $1.level }
    }
    
    var min: Double {
        floor(sortedByLevel.last?.level ?? 0)
    }
    
    var max: Double {
        ceil(sortedByLevel.first?.level ?? 0)
    }
    
    var color: Color {
        data.alert.color()
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
                    Image(systemName: data.alert.symbol())
                        .foregroundStyle(.secondary)
                    
                    Text(data.alert.text())
                        .kerning(-0.4)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    
                    if widgetFamily != .systemSmall {
                        Text(data.name)
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
                            Text(String(Int(round(data.delta*100)))+"cm")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                        
                        Image(systemName: data.delta > 0 ? "chevron.up" : "chevron.down")
                            .font(.title2.bold())
                    }
                }
            }
            .foregroundStyle(.white)
        }
    }
}


#Preview {
    FlussWidgetView(data: .sample)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
}
