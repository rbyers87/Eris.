//
//  ModelPickerView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import MLXLMCommon

struct ModelPickerView: View {
    @StateObject private var modelManager = ModelManager.shared
    let selectedModel: MLXLMCommon.ModelConfiguration?
    let onSelect: (MLXLMCommon.ModelConfiguration) -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(modelManager.downloadedModels.sorted(), id: \.self) { modelName in
                    if let model = MLXLMCommon.ModelConfiguration.getModelByName(modelName) {
                        ModelPickerRow(
                            model: model,
                            isSelected: selectedModel?.name == model.name,
                            onTap: {
                                HapticManager.shared.selection()
                                onSelect(model)
                            }
                        )
                    }
                }
            } header: {
                Text("Downloaded Models")
            }
            
            if modelManager.downloadedModels.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.down.circle.dotted")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        
                        Text("No models downloaded")
                            .font(.headline)
                        
                        Text("Go to Settings to download models")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct ModelPickerRow: View {
    let model: MLXLMCommon.ModelConfiguration
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatModelName(model))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(model.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatModelName(_ model: MLXLMCommon.ModelConfiguration) -> String {
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
        ModelPickerView(selectedModel: nil) { _ in }
    }
}