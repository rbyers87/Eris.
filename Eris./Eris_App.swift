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
    @AppStorage("appTheme") private var appTheme: String = "system"
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Thread.self, Message.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        // Initialize memory manager to handle memory warnings
        _ = MemoryManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .preferredColorScheme(colorScheme)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
