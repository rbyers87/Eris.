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
    @State private var lastHapticTokenCount = 0
    @State private var isScrolledToBottom = true
    
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
                .onChange(of: llmEvaluator.output) { _, _ in
                    // Auto-scroll as AI generates text
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onChange(of: llmEvaluator.tokensGenerated) { _, newTokenCount in
                    // Check if we're generating a code block
                    let codeBlockStarts = llmEvaluator.output.components(separatedBy: "```").count - 1
                    let isGeneratingCode = codeBlockStarts % 2 == 1
                    
                    // Haptic feedback only if we're scrolled to bottom and NOT generating code
                    if isScrolledToBottom && !isGeneratingCode && newTokenCount > lastHapticTokenCount + 12 {
                        // Alternate between different haptic patterns
                        let hapticCount = newTokenCount / 12
                        switch hapticCount % 3 {
                        case 0:
                            HapticManager.shared.impact(.soft)
                        case 1:
                            HapticManager.shared.impact(.light)
                        default:
                            HapticManager.shared.selection()
                        }
                        lastHapticTokenCount = newTokenCount
                    }
                }
                .onAppear {
                    // Scroll to bottom when view appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
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
                        .foregroundStyle(Color(UIColor.label))
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
        
        // Check if thread is persisted, if not, insert it now
        if thread.modelContext == nil {
            modelContext.insert(thread)
        }
        
        // Add user message
        let userMessage = Message(content: inputText, role: .user)
        thread.addMessage(userMessage)
        
        // Update title after first message
        updateTitle()
        
        let prompt = inputText
        inputText = ""
        
        // Generate response
        Task {
            // Haptic when AI starts generating
            HapticManager.shared.processingStart()
            
            let systemPrompt = """
            You are Eris, a helpful AI assistant integrated into the Eris app - a privacy-focused iOS application that runs language models entirely on-device. 
            
            Key facts about yourself and the app:
            - You run locally on the user's iPhone/iPad without any cloud connectivity
            - All conversations are stored privately on the device
            - You are powered by various open-source models (Llama, Qwen, Mistral, etc.)
            - The app prioritizes user privacy and data security
            - You support markdown formatting and code syntax highlighting
            
            Be helpful, concise, and privacy-conscious in your responses.
            """
            
            let response = await llmEvaluator.generate(thread: thread, systemPrompt: systemPrompt)
            
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
        if message.role == .user {
            // User message with bubble on the right
            HStack(alignment: .bottom, spacing: 8) {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    MessageView(content: message.content, isUser: true)
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
            }
        } else {
            // Assistant message full width
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    // Assistant avatar
                    Image("AppIconNoBg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .opacity(0.8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Eris")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        MessageView(content: message.content, isUser: false)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = message.content
                                    HapticManager.shared.notification(.success)
                                }) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                            }
                    }
                    
                    Spacer()
                }
                
                if showTimestamp {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 38)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .onTapGesture {
                HapticManager.shared.impact(.light)
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTimestamp.toggle()
                }
            }
        }
    }
}

struct TypingIndicator: View {
    let text: String
    @State private var animationAmount = 0.0
    
    private var isGeneratingCodeBlock: Bool {
        // Check if we have an unclosed code block
        let codeBlockStarts = text.components(separatedBy: "```").count - 1
        return codeBlockStarts % 2 == 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                // Assistant avatar
                Image("AppIconNoBg")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .opacity(0.8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Eris")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
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
                        .padding(.vertical, 8)
                        .onAppear {
                            animationAmount = 1.0
                        }
                    } else if isGeneratingCodeBlock {
                        // Show code generation indicator
                        VStack(alignment: .leading, spacing: 8) {
                            // Show the text before the code block
                            if let lastCodeBlockRange = text.range(of: "```", options: .backwards) {
                                let textBeforeCode = String(text[..<lastCodeBlockRange.lowerBound])
                                if !textBeforeCode.isEmpty {
                                    MessageView(content: textBeforeCode, isUser: false)
                                }
                            }
                            
                            // Code generation indicator
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Generating code...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    } else {
                        // Streaming text
                        MessageView(content: text, isUser: false)
                    }
                }
                
                Spacer()
            }
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