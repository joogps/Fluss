//
//  FlussAccessoryWidgets.swift
//  FlussWidgetExtension
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

import WidgetKit
import SwiftUI

#if os(iOS)
struct FlussWaterLevelAccessoryWidget: Widget {
    let kind: String = "FlussSmallWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: FlussWidgetProvider()) { entry in
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
    
    func content(entry: FlussWidgetEntry) -> some View {
        if entry.data.alert == .failure {
            FlussAccessoryWidgetView(systemImage: entry.data.alert.symbol(),
                                 title: "")
        } else {
            FlussAccessoryWidgetView(systemImage: entry.data.alert.symbol(),
                                 title: String(entry.data.currentReading?.level ?? 0)+"m")
        }
    }
}

struct FlussWaterDeltaAccessoryWidget: Widget {
    let kind: String = "FlussSmallWidget2"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: FlussWidgetProvider()) { entry in
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
    
    func content(entry: FlussWidgetEntry) -> some View {
        if entry.data.alert == .failure {
            FlussAccessoryWidgetView(systemImage: entry.data.alert.symbol(),
                                 title: "")
        } else {
            FlussAccessoryWidgetView(systemImage: entry.data.delta > 0 ? "chevron.up" : "chevron.down",
                                 title: String(Int(round(entry.data.delta*100)))+"cm")
        }
    }
}
#endif
