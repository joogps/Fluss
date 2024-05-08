//
//  FlussLiveActivity.swift
//  FlussWidgetExtension
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

#if os(iOS)
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct FlussLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ReadingDataAttributes.self) { context in
            FlussWidgetView(data: context.state.data)
                .padding()
                .background {
                    context.state.data.alert.color()
                        .overlay(Color(white: 0.03).blendMode(.luminosity))
                }
        } dynamicIsland: { context in
            let data = context.state.data
            
            return DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.center, content: {
                    FlussWidgetView(data: data)
                })
            }, compactLeading: {
                Image(systemName: data.alert.symbol())
                    .foregroundStyle(data.alert.color())
            }, compactTrailing: {
                if let nivel = data.currentReading {
                    Text(String(format: "%.2f", nivel.level)+"m")
                        .foregroundStyle(data.alert.color())
                        .bold()
                }
            }, minimal: {
                if let nivel = data.currentReading {
                    Text(String(format: "%.2f", nivel.level)+"m")
                        .foregroundStyle(data.alert.color())
                        .bold()
                }
            })
        }
    }
}
#endif
