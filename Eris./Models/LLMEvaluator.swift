//
//  LLMEvaluator.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import SwiftUI

@MainActor
class LLMEvaluator: ObservableObject {
    @Published var running = false
    @Published var output = ""
    @Published var modelInfo = ""
    @Published var progress = 0.0
    @Published var tokensGenerated = 0
    
    private var modelConfiguration: ModelConfiguration?
    private let generateParameters = GenerateParameters(temperature: 0.7)
    private let maxTokens = 2048
    
    enum LoadState {
        case idle
        case loading
        case loaded(ModelContainer)
        case failed(Error)
    }
    
    var loadState = LoadState.idle
    
    func load() async throws -> ModelContainer {
        guard let modelConfiguration = ModelManager.shared.activeModel else {
            throw NSError(domain: "LLMEvaluator", code: 1, userInfo: [NSLocalizedDescriptionKey: "No model selected"])
        }
        switch loadState {
        case .idle, .failed:
            loadState = .loading
            
            // Limit GPU memory cache
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
            
            do {
                let modelContainer = try await LLMModelFactory.shared.loadContainer(
                    configuration: modelConfiguration
                ) { progress in
                    Task { @MainActor in
                        self.modelInfo = "Downloading: \(Int(progress.fractionCompleted * 100))%"
                        self.progress = progress.fractionCompleted
                    }
                }
                
                modelInfo = "Model loaded successfully"
                loadState = .loaded(modelContainer)
                return modelContainer
                
            } catch {
                loadState = .failed(error)
                throw error
            }
            
        case .loading:
            // Wait for current load
            while case .loading = loadState {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            return try await load()
            
        case let .loaded(modelContainer):
            return modelContainer
        }
    }
    
    func generate(thread: Thread, systemPrompt: String = "You are a helpful assistant.") async -> String {
        guard !running else { return "" }
        
        running = true
        output = ""
        tokensGenerated = 0
        
        do {
            let modelContainer = try await load()
            
            // Prepare conversation history
            var messages: [[String: String]] = []
            
            // Add system prompt
            messages.append([
                "role": "system",
                "content": systemPrompt
            ])
            
            // Add conversation history
            for message in thread.sortedMessages {
                messages.append([
                    "role": message.role.rawValue,
                    "content": message.content
                ])
            }
            
            // Generate random seed
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
            
            let result = try await modelContainer.perform { context in
                let input = try await context.processor.prepare(input: .init(messages: messages))
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: generateParameters,
                    context: context
                ) { tokens in
                    // Update output periodically
                    if tokens.count % 4 == 0 {
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor in
                            self.output = text
                            self.tokensGenerated = tokens.count
                        }
                    }
                    
                    return tokens.count >= maxTokens ? .stop : .more
                }
            }
            
            output = result.output
            
        } catch {
            output = "Error: \(error.localizedDescription)"
        }
        
        running = false
        return output
    }
}