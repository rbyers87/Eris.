//
//  ModelConfiguration+Extensions.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import Foundation
import MLXLMCommon

public extension ModelConfiguration {
    static let llama3_2_1B = ModelConfiguration(
        id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
    )
    
    static let llama3_2_3B = ModelConfiguration(
        id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
    )
    
    static var availableModels: [ModelConfiguration] {
        [llama3_2_1B, llama3_2_3B]
    }
    
    static var defaultModel: ModelConfiguration {
        llama3_2_1B
    }
    
    static func getModelByName(_ name: String) -> ModelConfiguration? {
        availableModels.first { $0.name == name }
    }
}