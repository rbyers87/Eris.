//
//  ContentView.swift
//  Eris.
//
//  Created by Ignacio Palacio  on 19/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Thread.updatedAt, order: .reverse) private var threads: [Thread]
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            NavigationStack {
            List {
                ForEach(threads) { thread in
                    NavigationLink(destination: ChatView(thread: thread)) {
                        VStack(alignment: .leading) {
                            Text(thread.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if let lastMessage = thread.lastMessage {
                                Text(lastMessage.content)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        HapticManager.shared.selection()
                    })
                }
                .onDelete(perform: deleteThreads)
            }
            .navigationTitle("Eris.")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.shared.buttonTap()
                        createNewThread()
                    }) {
                        Image(systemName: "plus")
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.primary)
                    }
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        HapticManager.shared.selection()
                    })
                }
            }
            .overlay {
                if threads.isEmpty {
                    ContentUnavailableView(
                        "No Chats",
                        systemImage: "message",
                        description: Text("Tap + to start a new chat")
                    )
                }
            }
            }
        }
    }
    
    private func createNewThread() {
        let newThread = Thread()
        modelContext.insert(newThread)
        try? modelContext.save()
    }
    
    private func deleteThreads(at offsets: IndexSet) {
        HapticManager.shared.impact(.medium)
        for index in offsets {
            modelContext.delete(threads[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
}
