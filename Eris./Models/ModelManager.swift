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
        
        // Set cache limit based on device
        let cacheLimit: Int
        switch DeviceUtils.chipFamily {
        case .a13, .a14:
            cacheLimit = 32 * 1024 * 1024 // 32MB for download phase
        default:
            cacheLimit = 64 * 1024 * 1024 // 64MB for other devices
        }
        MLX.GPU.set(cacheLimit: cacheLimit)
        
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
        
        // Try to delete model files from disk
        deleteModelFiles(for: model)
    }
    
    func deleteAllModels() {
        // Clear all models
        downloadedModels.removeAll()
        saveDownloadedModels()
        
        // Clear active model
        activeModel = nil
        userDefaults.removeObject(forKey: activeModelKey)
        
        // Delete all model files
        for model in ModelConfiguration.availableModels {
            deleteModelFiles(for: model)
        }
    }
    
    private func deleteModelFiles(for model: ModelConfiguration) {
        let fileManager = FileManager.default
        
        // Try to find and delete model files in Documents/huggingface
        if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelPath = documentsPath
                .appendingPathComponent("huggingface")
                .appendingPathComponent("models")
                .appendingPathComponent(model.name)
            
            do {
                if fileManager.fileExists(atPath: modelPath.path) {
                    try fileManager.removeItem(at: modelPath)
                    print("Deleted model files at: \(modelPath)")
                }
            } catch {
                print("Error deleting model files: \(error)")
            }
        }
    }
}