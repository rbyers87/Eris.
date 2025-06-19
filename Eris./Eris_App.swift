//
//  Eris_App.swift
//  Eris.
//
//  Created by Ignacio Palacio  on 19/6/25.
//

import SwiftUI
import SwiftData

@main
struct Eris_App: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Thread.self, Message.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
