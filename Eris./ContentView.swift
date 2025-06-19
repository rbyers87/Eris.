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
    
    private var shouldShowOnboarding: Bool {
        #if DEBUG
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        return showOnboarding && !isPreview
        #else
        return showOnboarding
        #endif
    }
    
    var body: some View {
        if shouldShowOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            NavigationStack {
                VStack(spacing: 0) {
                    // Custom header
                    HStack(spacing: 12) {
                        Image("AppIconNoBg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                        
                        Text("Eris.")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundStyle(Color(UIColor.label))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .simultaneousGesture(TapGesture().onEnded { _ in
                            HapticManager.shared.selection()
                        })
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemBackground))
                    
                    Divider()
                    
                    // Threads list
                    if threads.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image("AppIconNoBg")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .opacity(0.3)
                            
                            VStack(spacing: 8) {
                                Text("No conversations yet")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Start a new chat to begin")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                createNewThreadAndNavigate()
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.body)
                                    Text("New Chat")
                                        .font(.headline)
                                }
                                .foregroundStyle(Color(UIColor.systemBackground))
                                .frame(width: 140, height: 44)
                                .background(Color(UIColor.label))
                                .cornerRadius(22)
                            }
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(threads) { thread in
                                    NavigationLink(destination: ChatView(thread: thread)) {
                                        ThreadRow(thread: thread)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(UIColor.secondarySystemBackground))
                                            )
                                    }
                                    .buttonStyle(ThreadButtonStyle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteThread(thread)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded { _ in
                                        HapticManager.shared.selection()
                                    })
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 80) // Space for floating button
                        }
                    }
                }
                .navigationBarHidden(true)
                .background(
                    NavigationLink(
                        destination: newThread.map { ChatView(thread: $0) },
                        isActive: $navigateToNewChat
                    ) {
                        EmptyView()
                    }
                )
                .overlay(
                    // Floating action button
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                HapticManager.shared.buttonTap()
                                createNewThreadAndNavigate()
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.systemBackground))
                                    .frame(width: 56, height: 56)
                                    .background(Color(UIColor.label))
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                )
            }
        }
    }
    
    private func createNewThread() {
        let newThread = Thread()
        modelContext.insert(newThread)
        try? modelContext.save()
    }
    
    @State private var newThread: Thread?
    @State private var navigateToNewChat = false
    @State private var showFloatingButton = true
    
    private func createNewThreadAndNavigate() {
        let thread = Thread()
        modelContext.insert(thread)
        try? modelContext.save()
        newThread = thread
        navigateToNewChat = true
    }
    
    private func deleteThreads(at offsets: IndexSet) {
        HapticManager.shared.impact(.medium)
        for index in offsets {
            modelContext.delete(threads[index])
        }
        try? modelContext.save()
    }
    
    private func deleteThread(_ thread: Thread) {
        HapticManager.shared.impact(.medium)
        modelContext.delete(thread)
        try? modelContext.save()
    }
}

struct ThreadRow: View {
    let thread: Thread
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(thread.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                if let lastMessage = thread.lastMessage {
                    Text(lastMessage.content)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Text(timeAgoString(from: thread.updatedAt))
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ThreadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
