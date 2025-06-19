//
//  ModelManager.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import SwiftUI

@MainActor
class ModelManager: ObservableObject {
    @Published var downloadedModels: Set<String> = []
    @Published var activeModel: ModelConfiguration?
    
    private let userDefaults = UserDefaults.standard
    private let downloadedModelsKey = "downloadedModels"
    private let activeModelKey = "activeModel"
    
    static let shared = ModelManager()
    
    init() {
        loadDownloadedModels()
        loadActiveModel()
    }
    
    private func loadDownloadedModels() {
        if let saved = userDefaults.stringArray(forKey: downloadedModelsKey) {
            downloadedModels = Set(saved)
        }
    }
    
    private func loadActiveModel() {
        if let modelName = userDefaults.string(forKey: activeModelKey),
           let model = ModelConfiguration.getModelByName(modelName) {
            activeModel = model
        }
    }
    
    private func saveDownloadedModels() {
        userDefaults.set(Array(downloadedModels), forKey: downloadedModelsKey)
    }
    
    func isModelDownloaded(_ model: ModelConfiguration) -> Bool {
        downloadedModels.contains(model.name)
    }
    
    func setActiveModel(_ model: ModelConfiguration) {
        activeModel = model
        userDefaults.set(model.name, forKey: activeModelKey)
    }
    
    func downloadModel(_ model: ModelConfiguration, progressHandler: @escaping (Progress) -> Void) async throws {
        print("Starting download for model: \(model.name)")
        
        // Set cache limit
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        
        do {
            // Download the model
            print("Calling LLMModelFactory.shared.loadContainer")
            _ = try await LLMModelFactory.shared.loadContainer(
                configuration: model,
                progressHandler: { progress in
                    print("Download progress: \(progress.fractionCompleted)")
                    progressHandler(progress)
                }
            )
            
            print("Model downloaded successfully")
            
            // Mark as downloaded
            downloadedModels.insert(model.name)
            saveDownloadedModels()
            
            // If no active model, set this as active
            if activeModel == nil {
                setActiveModel(model)
            }
        } catch {
            print("Error downloading model: \(error)")
            throw error
        }
    }
    
    func deleteModel(_ model: ModelConfiguration) {
        // Remove from downloaded models
        downloadedModels.remove(model.name)
        saveDownloadedModels()
        
        // If this was the active model, clear it
        if activeModel?.name == model.name {
            activeModel = nil
            userDefaults.removeObject(forKey: activeModelKey)
        }
        
        // Note: MLX doesn't provide a direct way to delete models from cache
        // The models are stored in the system's cache directory and will be
        // cleaned up by the system when needed
    }
}