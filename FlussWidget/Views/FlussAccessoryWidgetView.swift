//
//  FlussAccessoryWidgetView.swift
//  FlussWidgetExtension
//
//  Created by João Gabriel Pozzobon dos Santos on 07/05/24.
//

import SwiftUI
import WidgetKit

struct FlussAccessoryWidgetView: View {
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

#Preview {
    FlussAccessoryWidgetView(systemImage: "circle", title: "Title")
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))
}
