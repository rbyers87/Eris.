//
//  ModelConfiguration+Extensions.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import Foundation
import MLXLMCommon

public extension ModelConfiguration {
    // Llama Models
    static let llama3_2_1B = ModelConfiguration(
        id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
    )
    
    static let llama3_2_3B = ModelConfiguration(
        id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
    )
    
    // DeepSeek Reasoning Models
    static let deepseekR1DistillQwen1_5B_4bit = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit"
    )
    
    static let deepseekR1DistillQwen1_5B_8bit = ModelConfiguration(
        id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit"
    )
    
    // Qwen Models
    static let qwen2_5_0_5B = ModelConfiguration(
        id: "mlx-community/Qwen2.5-0.5B-Instruct-4bit"
    )
    
    static let qwen2_5_1_5B = ModelConfiguration(
        id: "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    )
    
    static let qwen2_5_3B = ModelConfiguration(
        id: "mlx-community/Qwen2.5-3B-Instruct-4bit"
    )
    
    // Gemma Models
    static let gemma2_2B = ModelConfiguration(
        id: "mlx-community/gemma-2-2b-it-4bit"
    )
    
    // Phi Models
    static let phi3_5Mini = ModelConfiguration(
        id: "mlx-community/Phi-3.5-mini-instruct-4bit"
    )
    
    // Code Models
    static let codeLlama7B = ModelConfiguration(
        id: "mlx-community/CodeLlama-7b-Instruct-hf-4bit"
    )
    
    static let stableCode3B = ModelConfiguration(
        id: "mlx-community/stable-code-instruct-3b-4bit"
    )
    
    // Mistral Models
    static let mistral7B = ModelConfiguration(
        id: "mlx-community/Mistral-7B-Instruct-v0.3-4bit"
    )
    
    static var availableModels: [ModelConfiguration] {
        [
            llama3_2_1B,
            llama3_2_3B,
            deepseekR1DistillQwen1_5B_4bit,
            deepseekR1DistillQwen1_5B_8bit,
            qwen2_5_0_5B,
            qwen2_5_1_5B,
            qwen2_5_3B,
            gemma2_2B,
            phi3_5Mini,
            codeLlama7B,
            stableCode3B,
            mistral7B
        ]
    }
    
    static var defaultModel: ModelConfiguration {
        llama3_2_1B
    }
    
    static func getModelByName(_ name: String) -> ModelConfiguration? {
        availableModels.first { $0.name == name }
    }
}