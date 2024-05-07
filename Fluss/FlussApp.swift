//
//  FlussApp.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import SwiftUI
import AVKit
import WidgetKit

@main
struct FlussApp: App {
    var body: some Scene {
        #if os(iOS)
        WindowGroup {
            ContentView()
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                    
                    do {
                        try? AVAudioSession
                            .sharedInstance()
                            .setCategory(.playback, options: [.mixWithOthers])
                        
                        try? AVAudioSession
                            .sharedInstance()
                            .setActive(true)
                    }
                }
        }
        #elseif os(macOS)
        MenuBarExtra {
            MacContentView()
        } label: {
            Image(systemName: "chevron.up.chevron.down")
        }
        .menuBarExtraStyle(WindowMenuBarExtraStyle())
        #endif
    }
}
