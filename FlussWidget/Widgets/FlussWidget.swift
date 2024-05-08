//
//  FlussWidget.swift
//  FlussWidget
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import WidgetKit
import SwiftUI

struct FlussWidget: Widget {
    let kind: String = "FlussWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectRegionIntent.self, provider: FlussWidgetProvider()) { entry in
            let background = entry.data.alert.color()
                .overlay(Color(white: 0.03).blendMode(.luminosity))
            
            if #available(macOS 14.0, iOS 17.0, *) {
                FlussWidgetView(data: entry.data)
                    .containerBackground(for: .widget) {
                        background
                    }
            } else {
                FlussWidgetView(data: entry.data)
                    .padding()
                    .background(background)
            }
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Situação da enchente")
        .description("Monitore a variação do nível da água ao longo das últimas horas.")
    }
}
