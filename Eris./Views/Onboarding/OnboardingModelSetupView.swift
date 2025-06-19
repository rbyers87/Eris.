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
                    ForEach(ModelConfiguration.availableModels, id: \.name) { model in
                        ModelSelectionCard(
                            model: model,
                            isSelected: selectedModel?.name == model.name,
                            isDownloaded: modelManager.isModelDownloaded(model),
                            isRecommended: model.name == ModelConfiguration.llama3_2_1B.name
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
            // Auto-select recommended model
            if selectedModel == nil {
                selectedModel = ModelConfiguration.llama3_2_1B
            }
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
                            
                            Spacer()
                        }
                        
                        Text(modelDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
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