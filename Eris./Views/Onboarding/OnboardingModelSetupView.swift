//
//  OnboardingModelSetupView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import MLXLMCommon

struct OnboardingModelSetupView: View {
    @Binding var showOnboarding: Bool
    @StateObject private var modelManager = ModelManager.shared
    @State private var selectedModel: ModelConfiguration?
    @State private var showCompatibilityWarning = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                Image(systemName: "arrow.down.circle.dotted")
                    .font(.system(size: 60))
                    .foregroundStyle(.primary)
                
                VStack(spacing: 8) {
                    Text("Choose Your Model")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Select an AI model to download and start chatting")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            // Device compatibility check
            if !DeviceUtils.canRunMLX {
                DeviceCompatibilityCard()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Models list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sortedModels(), id: \.name) { model in
                        ModelSelectionCard(
                            model: model,
                            isSelected: selectedModel?.name == model.name,
                            isDownloaded: modelManager.isModelDownloaded(model),
                            isRecommended: model.name == getRecommendedModelForDevice().name && model.compatibilityForDevice() == .recommended
                        ) {
                            HapticManager.shared.selection()
                            selectedModel = model
                        }
                        .disabled(!DeviceUtils.canRunMLX)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Continue button
            if DeviceUtils.canRunMLX {
                NavigationLink(
                    destination: OnboardingDownloadView(
                        showOnboarding: $showOnboarding,
                        selectedModel: selectedModel ?? ModelConfiguration.llama3_2_1B
                    )
                ) {
                    Text("Download Model")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedModel != nil ? Color(UIColor.label) : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(selectedModel == nil)
                .simultaneousGesture(TapGesture().onEnded { _ in
                    if selectedModel != nil {
                        HapticManager.shared.buttonTap()
                    }
                })
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Auto-select best model for device
            if selectedModel == nil {
                selectedModel = getRecommendedModelForDevice()
            }
        }
    }
    
    private func getRecommendedModelForDevice() -> ModelConfiguration {
        let chipFamily = DeviceUtils.chipFamily
        
        switch chipFamily {
        case .a13, .a14:
            // iPhone 11, 12 - Recommend smallest model
            return ModelConfiguration.qwen2_5_0_5B
        case .a15:
            // iPhone 13, 14 - Recommend 1B model
            return ModelConfiguration.llama3_2_1B
        case .a16, .a17Pro, .a18, .a18Pro:
            // iPhone 14 Pro, 15, 16 - Can handle 1-3B models well
            return ModelConfiguration.llama3_2_1B
        case .m1, .m2, .m3, .m4:
            // iPad M-series - Can handle larger models
            return ModelConfiguration.llama3_2_3B
        default:
            return ModelConfiguration.llama3_2_1B
        }
    }
    
    private func sortedModels() -> [ModelConfiguration] {
        let models = ModelConfiguration.availableModels
        let recommendedModel = getRecommendedModelForDevice()
        
        return models.sorted { model1, model2 in
            // Put recommended model first
            if model1.name == recommendedModel.name { return true }
            if model2.name == recommendedModel.name { return false }
            
            // Then sort by compatibility
            let compat1 = model1.compatibilityForDevice()
            let compat2 = model2.compatibilityForDevice()
            
            if compat1 == .recommended && compat2 != .recommended { return true }
            if compat2 == .recommended && compat1 != .recommended { return false }
            
            if compat1 == .compatible && compat2 == .risky { return true }
            if compat1 == .compatible && compat2 == .notRecommended { return true }
            
            if compat1 == .risky && compat2 == .notRecommended { return true }
            
            return false
        }
    }
}

struct DeviceCompatibilityCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Device Compatibility")
                    .font(.headline)
                Spacer()
            }
            
            Text(DeviceUtils.compatibilityMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ModelSelectionCard: View {
    let model: ModelConfiguration
    let isSelected: Bool
    let isDownloaded: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    var modelSize: String {
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
    
    var modelDescription: String {
        switch model.name {
        case ModelConfiguration.llama3_2_1B.name:
            return "Fast and efficient, perfect for quick conversations"
        case ModelConfiguration.llama3_2_3B.name:
            return "More capable, better for complex tasks"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_4bit.name:
            return "Advanced reasoning with step-by-step thinking"
        case ModelConfiguration.deepseekR1DistillQwen1_5B_8bit.name:
            return "Higher precision reasoning model"
        case ModelConfiguration.qwen2_5_0_5B.name:
            return "Ultra-lightweight for basic tasks"
        case ModelConfiguration.qwen2_5_1_5B.name:
            return "Balanced performance and efficiency"
        case ModelConfiguration.qwen2_5_3B.name:
            return "Strong multilingual capabilities"
        case ModelConfiguration.gemma2_2B.name:
            return "Google's efficient instruction-following model"
        case ModelConfiguration.phi3_5Mini.name:
            return "Microsoft's powerful small language model"
        case ModelConfiguration.codeLlama7B.name:
            return "Specialized for code generation and analysis"
        case ModelConfiguration.stableCode3B.name:
            return "Efficient coding assistant for developers"
        case ModelConfiguration.mistral7B.name:
            return "Versatile and powerful for all tasks"
        default:
            return ""
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(formatModelName(model))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if isRecommended {
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
                            
                            Spacer()
                        }
                        
                        Text(modelDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Compatibility indicator
                        let compatibility = model.compatibilityForDevice()
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
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        if isDownloaded {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .primary : .gray)
                        }
                        
                        Text(modelSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                if isDownloaded {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primary)
                            .font(.caption)
                        Text("Already downloaded")
                            .font(.caption)
                            .foregroundColor(.primary)
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
                            .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatModelName(_ model: ModelConfiguration) -> String {
        let name = model.name
            .replacingOccurrences(of: "mlx-community/", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "Instruct", with: "")
            .replacingOccurrences(of: "4bit", with: "")
        
        return name.trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    NavigationStack {
        OnboardingModelSetupView(showOnboarding: .constant(true))
    }
}