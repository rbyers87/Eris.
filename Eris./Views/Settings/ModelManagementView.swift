//
//  ModelManagementView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import MLXLMCommon

struct ModelManagementView: View {
    @StateObject private var modelManager = ModelManager()
    @State private var selectedModel: ModelConfiguration?
    
    var body: some View {
        NavigationView {
            if DeviceUtils.isSimulator {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Simulator Detected")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("MLX models require Apple Silicon hardware.\nPlease run this app on:")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("iPhone 15 Pro or later", systemImage: "iphone")
                        Label("iPad with M-series chip", systemImage: "ipad")
                        Label("Mac with Apple Silicon", systemImage: "macbook")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .navigationTitle("Models")
            } else {
                List {
                    ForEach(ModelConfiguration.availableModels, id: \.name) { model in
                        ModelRowView(
                            model: model,
                            modelManager: modelManager,
                            isSelected: selectedModel?.name == model.name
                        )
                        .onTapGesture {
                            if modelManager.isModelDownloaded(model) {
                                selectedModel = model
                                modelManager.setActiveModel(model)
                            }
                        }
                    }
                }
                .navigationTitle("Models")
                .onAppear {
                    selectedModel = modelManager.activeModel
                }
                .toolbar {
                    #if DEBUG
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Reset Onboarding") {
                            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                            exit(0)
                        }
                        .foregroundColor(.red)
                    }
                    #endif
                }
            }
        }
    }
}

struct ModelRowView: View {
    let model: ModelConfiguration
    @ObservedObject var modelManager: ModelManager
    let isSelected: Bool
    
    @State private var downloadProgress: Double = 0.0
    @State private var isDownloading = false
    
    func formatModelId(_ model: ModelConfiguration) -> String {
        // Extract a readable format from the model configuration
        let modelString = "\(model.id)"
        if modelString.contains("mlx-community/") {
            return modelString.replacingOccurrences(of: "mlx-community/", with: "")
        }
        return modelString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(model.name)
                        .font(.headline)
                    Text(formatModelId(model))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                if modelManager.isModelDownloaded(model) {
                    Menu {
                        Button(role: .destructive) {
                            modelManager.deleteModel(model)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                } else if isDownloading {
                    ProgressView(value: downloadProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Button {
                        print("Download button tapped")
                        downloadModel()
                    } label: {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if isDownloading && downloadProgress > 0 {
                ProgressView(value: downloadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text("\(Int(downloadProgress * 100))% downloaded")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func downloadModel() {
        print("Download button pressed for model: \(model.name)")
        isDownloading = true
        downloadProgress = 0.0
        
        Task {
            do {
                print("Starting download task")
                try await modelManager.downloadModel(model) { progress in
                    Task { @MainActor in
                        self.downloadProgress = progress.fractionCompleted
                        print("UI Progress update: \(self.downloadProgress)")
                    }
                }
                
                await MainActor.run {
                    isDownloading = false
                    downloadProgress = 0.0
                    print("Download completed")
                }
            } catch {
                await MainActor.run {
                    isDownloading = false
                    downloadProgress = 0.0
                }
                print("Download failed with error: \(error.localizedDescription)")
            }
        }
    }
}