//
//  FlussWidgetBundle.swift
//  FlussWidget
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import WidgetKit
import SwiftUI

@main
struct FlussWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        FlussWidget()
        #if os(iOS)
        FlussSmallWidget()
        FlussSmallWidget2()
        
        if #available(iOS 16.1, *) {
            FlussWidgetLiveActivity()
        }
        #endif
    }
}
