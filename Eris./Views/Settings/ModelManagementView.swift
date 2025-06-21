//
//  ModelManagementView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import MLXLMCommon

struct ModelManagementView: View {
    @StateObject private var modelManager = ModelManager.shared
    @State private var selectedModel: ModelConfiguration?
    @State private var downloadingModels: Set<String> = []
    @State private var downloadProgress: [String: Double] = [:]
    @State private var showCompatibilityWarning = false
    @State private var modelToDownload: ModelConfiguration?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 20) {
                    Image(systemName: "cpu")
                        .font(.system(size: 60))
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 8) {
                        Text("AI Models")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Download and manage AI models for offline use")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Device compatibility check
                if DeviceUtils.isSimulator {
                    DeviceCompatibilityWarning()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                } else if !DeviceUtils.canRunMLX {
                    DeviceCompatibilityCard()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                // Models list
                VStack(spacing: 12) {
                    ForEach(ModelConfiguration.availableModels, id: \.name) { model in
                        ModelCard(
                            model: model,
                            isSelected: modelManager.activeModel?.name == model.name,
                            isDownloaded: modelManager.isModelDownloaded(model),
                            isDownloading: downloadingModels.contains(model.name),
                            downloadProgress: downloadProgress[model.name] ?? 0.0,
                            onSelect: {
                                HapticManager.shared.selection()
                                if modelManager.isModelDownloaded(model) {
                                    modelManager.setActiveModel(model)
                                }
                            },
                            onDownload: {
                                HapticManager.shared.buttonTap()
                                let compatibility = model.compatibilityForDevice()
                                if compatibility == .risky || compatibility == .notRecommended {
                                    modelToDownload = model
                                    showCompatibilityWarning = true
                                } else {
                                    downloadModel(model)
                                }
                            },
                            onDelete: {
                                HapticManager.shared.warning()
                                deleteModel(model)
                            }
                        )
                        .disabled(DeviceUtils.isSimulator || !DeviceUtils.canRunMLX)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Model Management")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedModel = modelManager.activeModel
        }
        .alert("Compatibility Warning", isPresented: $showCompatibilityWarning) {
            Button("Download Anyway", role: .destructive) {
                if let model = modelToDownload {
                    downloadModel(model)
                }
            }
            Button("Cancel", role: .cancel) {
                modelToDownload = nil
            }
        } message: {
            if let model = modelToDownload {
                let compatibility = model.compatibilityForDevice()
                if compatibility == .notRecommended {
                    Text("⚠️ This model has a HIGH RISK of crashing on your \(DeviceUtils.deviceDescription).\n\nIt requires more memory than your device typically has available. We strongly recommend choosing a smaller model.\n\nIf you proceed, the app will likely crash when trying to use this model.")
                } else {
                    Text("⚠️ This model may experience issues on your \(DeviceUtils.deviceDescription).\n\nYou might encounter crashes or slow performance. For best results, close all other apps before using.\n\nConsider trying a smaller model if you experience problems.")
                }
            }
        }
    }
    
    private func downloadModel(_ model: ModelConfiguration) {
        downloadingModels.insert(model.name)
        downloadProgress[model.name] = 0.0
        
        Task {
            do {
                try await modelManager.downloadModel(model) { progress in
                    Task { @MainActor in
                        downloadProgress[model.name] = progress.fractionCompleted
                    }
                }
                
                await MainActor.run {
                    downloadingModels.remove(model.name)
                    downloadProgress.removeValue(forKey: model.name)
                    HapticManager.shared.modelDownloadComplete()
                }
            } catch {
                await MainActor.run {
                    downloadingModels.remove(model.name)
                    downloadProgress.removeValue(forKey: model.name)
                    HapticManager.shared.error()
                }
                print("Download failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteModel(_ model: ModelConfiguration) {
        modelManager.deleteModel(model)
        if modelManager.activeModel?.name == model.name {
            // If deleting the active model, try to set another downloaded model as active
            if let firstAvailableModel = ModelConfiguration.availableModels.first(where: { 
                $0.name != model.name && modelManager.isModelDownloaded($0) 
            }) {
                modelManager.setActiveModel(firstAvailableModel)
            }
            // If no other models are downloaded, activeModel will be cleared automatically
        }
    }
}

struct DeviceCompatibilityWarning: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Simulator Detected")
                    .font(.headline)
                Spacer()
            }
            
            Text("MLX models require real Apple Silicon hardware. Please run this app on a physical device.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            VStack(alignment: .leading, spacing: 8) {
                Label("iPhone 11 or later", systemImage: "iphone")
                    .font(.caption)
                Label("iPad with A12 chip or later", systemImage: "ipad")
                    .font(.caption)
                Label("Mac with Apple Silicon", systemImage: "macbook")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ModelCard: View {
    let model: ModelConfiguration
    let isSelected: Bool
    let isDownloaded: Bool
    let isDownloading: Bool
    let downloadProgress: Double
    let onSelect: () -> Void
    let onDownload: () -> Void
    let onDelete: () -> Void
    
    private var modelSize: String {
        switch model.name {
        case ModelConfiguration.llama3_2_1B.name:
            return "0.7 GB"
        case ModelConfiguration.llama3_2_3B.name:
            return "1.8 GB"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_4bit.name:
            return "1.0 GB"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_8bit.name:
            return "1.9 GB"
        case ModelConfiguration.qwen2_5_0_5B.name:
            return "0.4 GB"
        case ModelConfiguration.qwen2_5_1_5B.name:
            return "1.0 GB"
        case ModelConfiguration.qwen2_5_3B.name:
            return "2.0 GB"
        case ModelConfiguration.gemma2_2B.name:
            return "1.3 GB"
        case ModelConfiguration.phi3_5Mini.name:
            return "2.5 GB"
        case ModelConfiguration.codeLlama7B.name:
            return "3.9 GB"
        case ModelConfiguration.stableCode3B.name:
            return "1.6 GB"
        case ModelConfiguration.mistral7B.name:
            return "4.0 GB"
        default:
            return "Size unknown"
        }
    }
    
    private var modelDescription: String {
        switch model.name {
        case ModelConfiguration.llama3_2_1B.name:
            return "Fast and efficient for quick responses"
        case ModelConfiguration.llama3_2_3B.name:
            return "More capable for complex tasks"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_4bit.name:
            return "Advanced reasoning with chain-of-thought"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_8bit.name:
            return "Higher precision reasoning model"
        case ModelConfiguration.qwen2_5_0_5B.name:
            return "Ultra-lightweight for basic tasks"
        case ModelConfiguration.qwen2_5_1_5B.name:
            return "Balanced performance and efficiency"
        case ModelConfiguration.qwen2_5_3B.name:
            return "Strong multilingual capabilities"
        case ModelConfiguration.gemma2_2B.name:
            return "Google's efficient instruction model"
        case ModelConfiguration.phi3_5Mini.name:
            return "Microsoft's powerful small model"
        case ModelConfiguration.codeLlama7B.name:
            return "Specialized for code generation"
        case ModelConfiguration.stableCode3B.name:
            return "Efficient coding assistant"
        case ModelConfiguration.mistral7B.name:
            return "Versatile and powerful general model"
        default:
            return "AI language model"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(formatModelName(model))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if model.name == ModelConfiguration.llama3_2_1B.name {
                                Text("RECOMMENDED")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray)
                                    .cornerRadius(4)
                            }
                            
                            // Model category badges
                            if model.name.contains("DeepSeek") {
                                Text("REASONING")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.7))
                                    .cornerRadius(4)
                            } else if model.name.contains("Code") || model.name.contains("stable-code") {
                                Text("CODE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.7))
                                    .cornerRadius(4)
                            }
                        }
                        
                        Text(modelDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Compatibility indicator
                        HStack(spacing: 4) {
                            Image(systemName: model.compatibilityIcon)
                                .font(.caption)
                                .foregroundColor(model.compatibilityColor)
                            Text(model.compatibilityDescription)
                                .font(.caption)
                                .foregroundColor(model.compatibilityColor)
                            Spacer()
                        }
                        .padding(.top, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "internaldrive")
                                .font(.caption)
                            Text(modelSize)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        // Warning for large models on iPhone
                        if (model.name.contains("7B") || model.name.contains("7b")) && UIDevice.current.userInterfaceIdiom == .phone {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                Text("May run slowly on iPhone")
                                    .font(.caption2)
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    if isDownloading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                            Text("\(Int(downloadProgress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else if isDownloaded {
                        HStack(spacing: 12) {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            
                            Menu {
                                if !isSelected {
                                    Button(action: onSelect) {
                                        Label("Set as Active", systemImage: "checkmark.circle")
                                    }
                                }
                                Button(role: .destructive, action: onDelete) {
                                    Label("Delete Model", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Button(action: onDownload) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isDownloading && downloadProgress > 0 {
                VStack(spacing: 8) {
                    ProgressView(value: downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(UIColor.label)))
                    
                    HStack {
                        Text("Downloading...")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(downloadProgress * 100))%")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            
            if isDownloaded && !isSelected {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("Downloaded • Tap to activate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(UIColor.label) : Color.clear, lineWidth: 2)
                )
        )
    }
    
    private func formatModelName(_ model: ModelConfiguration) -> String {
        model.name
            .replacingOccurrences(of: "mlx-community/", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "Instruct", with: "")
            .replacingOccurrences(of: "4bit", with: "")
            .replacingOccurrences(of: "8bit", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    NavigationStack {
        ModelManagementView()
    }
}