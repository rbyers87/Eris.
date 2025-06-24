//
//  CreditsView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MLX Section
                    CreditSection(
                        title: "MLX Framework",
                        items: [
                            CreditItem(
                                name: "MLX",
                                description: "Machine learning framework for Apple Silicon",
                                url: "https://github.com/ml-explore/mlx",
                                license: "MIT License"
                            ),
                            CreditItem(
                                name: "MLX Swift",
                                description: "Swift API for MLX framework",
                                url: "https://github.com/ml-explore/mlx-swift",
                                license: "MIT License"
                            ),
                            CreditItem(
                                name: "MLX Swift Examples",
                                description: "Example implementations and models",
                                url: "https://github.com/ml-explore/mlx-swift-examples",
                                license: "MIT License"
                            )
                        ]
                    )
                    
                    // Third Party Libraries
                    CreditSection(
                        title: "Third Party Libraries",
                        items: [
                            CreditItem(
                                name: "Hugging Face Transformers",
                                description: "Swift implementation of transformers",
                                url: "https://github.com/huggingface/swift-transformers",
                                license: "Apache License 2.0"
                            ),
                            CreditItem(
                                name: "Jinja",
                                description: "Template engine for Swift",
                                url: "https://github.com/johnmai-dev/Jinja",
                                license: "MIT License"
                            ),
                            CreditItem(
                                name: "GzipSwift",
                                description: "Swift framework for gzip compression",
                                url: "https://github.com/1024jp/GzipSwift",
                                license: "MIT License"
                            ),
                            CreditItem(
                                name: "Swift Argument Parser",
                                description: "Type-safe argument parsing",
                                url: "https://github.com/apple/swift-argument-parser",
                                license: "Apache License 2.0"
                            ),
                            CreditItem(
                                name: "Swift Collections",
                                description: "Additional data structures for Swift",
                                url: "https://github.com/apple/swift-collections",
                                license: "Apache License 2.0"
                            ),
                            CreditItem(
                                name: "Swift Numerics",
                                description: "Numerical APIs for Swift",
                                url: "https://github.com/apple/swift-numerics",
                                license: "Apache License 2.0"
                            )
                        ]
                    )
                    
                    // Inspiration
                    CreditSection(
                        title: "Inspiration",
                        items: [
                            CreditItem(
                                name: "Fullmoon iOS",
                                description: "Private AI chat app that inspired Eris",
                                url: "https://github.com/mainframecomputer/fullmoon-ios",
                                license: "MIT License"
                            )
                        ]
                    )
                    
                    // Special Thanks
                    CreditSection(
                        title: "Special Thanks",
                        items: [
                            CreditItem(
                                name: "Apple Machine Learning Research",
                                description: "For creating and open-sourcing MLX",
                                url: "https://machinelearning.apple.com",
                                license: nil
                            ),
                            CreditItem(
                                name: "Hugging Face Community",
                                description: "For providing open models and tools",
                                url: "https://huggingface.co",
                                license: nil
                            ),
                            CreditItem(
                                name: "Open Source Community",
                                description: "For making projects like this possible",
                                url: nil,
                                license: nil
                            )
                        ]
                    )
                    
                    // License Notice
                    VStack(alignment: .leading, spacing: 8) {
                        Text("License Notice")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("This app includes software developed by the above projects and contributors. Each component is subject to its own license terms. Please refer to the individual project pages for complete license information.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreditSection: View {
    let title: String
    let items: [CreditItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.name) { index, item in
                    CreditItemView(item: item)
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
        }
    }
}

struct CreditItem {
    let name: String
    let description: String
    let url: String?
    let license: String?
}

struct CreditItemView: View {
    let item: CreditItem
    @State private var showSafari = false
    
    var body: some View {
        Button(action: {
            if item.url != nil {
                showSafari = true
                HapticManager.shared.impact(.light)
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let license = item.license {
                        Text(license)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                if item.url != nil {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(item.url == nil)
        .sheet(isPresented: $showSafari) {
            if let urlString = item.url,
               let url = URL(string: urlString) {
                SafariView(url: url)
            }
        }
    }
}

// Safari View Controller wrapper
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}

#Preview {
    CreditsView()
}