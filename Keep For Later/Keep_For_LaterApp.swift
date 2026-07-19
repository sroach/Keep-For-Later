//
//  Keep_For_LaterApp.swift
//  Keep For Later
//
//  Created by Steve Roach on 7/17/26.
//

import SwiftUI
import SwiftData

@main
struct Keep_For_LaterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedContainer.modelContainer)
    }
}
