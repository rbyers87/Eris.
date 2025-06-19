//
//  ChatView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import SwiftData
import MLXLMCommon

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var llmEvaluator = LLMEvaluator()
    @StateObject private var modelManager = ModelManager.shared
    @FocusState private var isInputFocused: Bool
    @State private var scrollToBottomTrigger = 0
    
    let thread: Thread
    
    @State private var inputText = ""
    @State private var isGenerating = false
    @State private var showNoModelAlert = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showModelPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        // Empty state
                        if thread.sortedMessages.isEmpty && !llmEvaluator.running {
                            EmptyChatView()
                                .padding(.top, 100)
                        }
                        
                        // Messages
                        ForEach(thread.sortedMessages, id: \.id) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        
                        // Typing indicator
                        if llmEvaluator.running {
                            TypingIndicator(text: llmEvaluator.output)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Bottom spacer for scroll
                        Color.clear
                            .frame(height: 20)
                            .id("bottom")
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: scrollToBottomTrigger) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: thread.messages.count) { _, _ in
                    scrollToBottomTrigger += 1
                }
                .onChange(of: llmEvaluator.running) { _, _ in
                    if llmEvaluator.running {
                        scrollToBottomTrigger += 1
                    }
                }
            }
            
            // Input area with model selector
            HStack(alignment: .bottom, spacing: 12) {
                // Model selector button
                Button(action: {
                    HapticManager.shared.selection()
                    showModelPicker.toggle()
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
                
                // Chat input
                ChatInputView(
                    text: $inputText,
                    isGenerating: llmEvaluator.running,
                    onSend: {
                        HapticManager.shared.messageSent()
                        sendMessage()
                    }
                )
                .focused($isInputFocused)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
            )
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let activeModel = modelManager.activeModel {
                    Text(formatModelName(activeModel))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .alert("No Model Selected", isPresented: $showNoModelAlert) {
            Button("Go to Settings") {
                // User needs to navigate to model management
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please download and select a model before chatting.")
        }
        .onAppear {
            updateTitle()
        }
        .sheet(isPresented: $showModelPicker) {
            NavigationStack {
                ModelPickerView(selectedModel: modelManager.activeModel) { model in
                    modelManager.setActiveModel(model)
                    showModelPicker = false
                }
                .navigationTitle("Select Model")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showModelPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        // Check if model is selected
        guard modelManager.activeModel != nil else {
            showNoModelAlert = true
            return
        }
        
        // Add user message
        let userMessage = Message(content: inputText, role: .user)
        thread.addMessage(userMessage)
        
        let prompt = inputText
        inputText = ""
        
        // Generate response
        Task {
            let response = await llmEvaluator.generate(thread: thread)
            
            // Add assistant message
            let assistantMessage = Message(content: response, role: .assistant)
            thread.addMessage(assistantMessage)
            
            // Haptic feedback for received message
            HapticManager.shared.messageReceived()
            
            // Save context
            try? modelContext.save()
        }
    }
    
    private func updateTitle() {
        // Auto-generate title from first message if needed
        if thread.title == "New Chat", 
           let firstUserMessage = thread.sortedMessages.first(where: { $0.role == .user }) {
            let words = firstUserMessage.content.split(separator: " ").prefix(5)
            thread.title = words.joined(separator: " ")
            if firstUserMessage.content.count > thread.title.count {
                thread.title += "..."
            }
        }
    }
    
    private func formatModelName(_ model: MLXLMCommon.ModelConfiguration) -> String {
        model.name
            .replacingOccurrences(of: "mlx-community/", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "Instruct", with: "")
            .replacingOccurrences(of: "4bit", with: "")
            .replacingOccurrences(of: "8bit", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Chat Components

struct MessageBubble: View {
    let message: Message
    @State private var showTimestamp = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 60)
            } else {
                // Assistant avatar
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.role == .user ? Color.gray : Color(UIColor.secondarySystemBackground))
                    )
                    .foregroundStyle(message.role == .user ? Color(UIColor.systemBackground) : .primary)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.content
                            HapticManager.shared.notification(.success)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                
                if showTimestamp {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .onTapGesture {
                HapticManager.shared.impact(.light)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTimestamp.toggle()
                }
            }
            
            if message.role != .user {
                Spacer(minLength: 60)
            }
        }
    }
}

struct TypingIndicator: View {
    let text: String
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Assistant avatar
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            if text.isEmpty {
                // Dots animation
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                            .scaleEffect(animationAmount)
                            .opacity(animationAmount)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: animationAmount
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .onAppear {
                    animationAmount = 1.0
                }
            } else {
                // Streaming text
                Text(text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .foregroundStyle(.primary)
            }
            
            Spacer(minLength: 60)
        }
    }
}

struct ChatInputView: View {
    @Binding var text: String
    let isGenerating: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .lineLimit(1...5)
                .disabled(isGenerating)
                .onSubmit {
                    if !text.isEmpty && !isGenerating {
                        onSend()
                    }
                }
                .frame(minHeight: 48)
            
            if isGenerating {
                Button(action: {
                    // Stop action would go here
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.primary)
                }
                .padding(.trailing, 12)
                .padding(.bottom, 12)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    onSend()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(text.isEmpty ? Color.gray : Color(UIColor.label))
                }
                .disabled(text.isEmpty)
                .padding(.trailing, 12)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("AppIconNoBg")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .opacity(0.3)
            
            VStack(spacing: 8) {
                Text("Start a conversation")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Type a message below to begin")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatView(thread: Thread())
            .modelContainer(for: [Thread.self, Message.self], inMemory: true)
    }
}