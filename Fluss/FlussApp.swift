//
//  FlussApp.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import SwiftUI

@main
struct FlussApp: App {
    var body: some Scene {
        #if os(iOS)
        WindowGroup {
            ContentView()
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
