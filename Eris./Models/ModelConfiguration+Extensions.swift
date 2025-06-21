//
//  ModelConfiguration+Extensions.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import Foundation
import MLXLMCommon
import SwiftUI

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
    
    enum ModelCompatibility {
        case recommended
        case compatible
        case risky
        case notRecommended
    }
    
    func compatibilityForDevice() -> ModelCompatibility {
        let chipFamily = DeviceUtils.chipFamily
        let modelSize = getModelSizeCategory()
        
        switch chipFamily {
        case .a13, .a14:
            // iPhone 11, 12 - 4GB RAM
            switch modelSize {
            case .tiny:
                return .compatible
            case .small:
                return .risky
            case .medium, .large:
                return .notRecommended
            }
        case .a15:
            // iPhone 13, 14 - 6GB RAM
            switch modelSize {
            case .tiny:
                return .recommended
            case .small:
                return .compatible
            case .medium:
                return .risky
            case .large:
                return .notRecommended
            }
        case .a16, .a17Pro, .a18, .a18Pro:
            // iPhone 14 Pro, 15, 16 - 6-8GB RAM
            switch modelSize {
            case .tiny, .small:
                return .recommended
            case .medium:
                return .compatible
            case .large:
                return .risky
            }
        case .m1, .m2, .m3, .m4:
            // iPad M-series - 8GB+ RAM
            return .recommended
        default:
            return .notRecommended
        }
    }
    
    private enum ModelSizeCategory {
        case tiny   // < 1B
        case small  // 1-2B
        case medium // 2-4B
        case large  // 4B+
    }
    
    private func getModelSizeCategory() -> ModelSizeCategory {
        let modelName = self.name.lowercased()
        
        if modelName.contains("0.5b") || modelName.contains("0_5b") {
            return .tiny
        } else if modelName.contains("1b") || modelName.contains("1.5b") || modelName.contains("1_5b") {
            return .small
        } else if modelName.contains("2b") || modelName.contains("3b") {
            return .medium
        } else {
            return .large
        }
    }
    
    var compatibilityDescription: String {
        switch compatibilityForDevice() {
        case .recommended:
            return "Recommended for your device"
        case .compatible:
            return "Compatible with your device"
        case .risky:
            return "May experience issues"
        case .notRecommended:
            return "Not recommended - High crash risk"
        }
    }
    
    var compatibilityIcon: String {
        switch compatibilityForDevice() {
        case .recommended:
            return "checkmark.circle.fill"
        case .compatible:
            return "checkmark.circle"
        case .risky:
            return "exclamationmark.triangle.fill"
        case .notRecommended:
            return "xmark.circle.fill"
        }
    }
    
    var compatibilityColor: Color {
        switch compatibilityForDevice() {
        case .recommended:
            return .green
        case .compatible:
            return .blue
        case .risky:
            return .orange
        case .notRecommended:
            return .red
        }
    }
}