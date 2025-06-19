//
//  SettingsView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @StateObject private var hapticManager = HapticManager.shared
    @StateObject private var modelManager = ModelManager.shared
    @State private var showAbout = false
    @State private var showCredits = false
    @State private var showDeveloper = false
    @State private var showSafari = false
    @State private var selectedURL: URL?
    @AppStorage("appTheme") private var appTheme: String = "system"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with app icon
                VStack(spacing: 16) {
                    Image("AppIconNoBg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    VStack(spacing: 4) {
                        Text("Eris.")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Settings sections
                VStack(spacing: 16) {
                        // Model Management
                        SettingsSection(title: "AI Models") {
                            NavigationLink(destination: ModelManagementView()) {
                                SettingsRow(
                                    icon: "cpu",
                                    title: "Model Management",
                                    subtitle: modelManager.activeModel?.name.replacingOccurrences(of: "mlx-community/", with: "") ?? "No model selected"
                                )
                            }
                            .buttonStyle(SettingsRowButtonStyle())
                        }
                        
                        // Preferences
                        SettingsSection(title: "Preferences") {
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Image(systemName: "moon.circle")
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .frame(width: 28, height: 28)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    Text("Theme")
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Picker("Theme", selection: $appTheme) {
                                        Text("System").tag("system")
                                        Text("Light").tag("light")
                                        Text("Dark").tag("dark")
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.primary)
                                    .onChange(of: appTheme) { _, _ in
                                        HapticManager.shared.selection()
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                SettingsToggleRow(
                                    icon: "hand.tap",
                                    title: "Haptic Feedback",
                                    subtitle: "Vibration feedback for interactions",
                                    isOn: $hapticManager.hapticsEnabled
                                )
                                .onChange(of: hapticManager.hapticsEnabled) { _, enabled in
                                    if enabled {
                                        HapticManager.shared.toggleSwitch()
                                    }
                                }
                            }
                        }
                        
                        // System
                        SettingsSection(title: "System") {
                            VStack(spacing: 0) {
                                SettingsInfoRow(
                                    icon: "iphone",
                                    title: "Device",
                                    value: DeviceUtils.deviceDescription
                                )
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                SettingsInfoRow(
                                    icon: "cpu",
                                    title: "Chip",
                                    value: DeviceUtils.chipDescription
                                )
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                SettingsInfoRow(
                                    icon: "checkmark.circle",
                                    title: "MLX Compatible",
                                    value: DeviceUtils.canRunMLX ? "Yes" : "No"
                                )
                            }
                        }
                        
                        // Legal
                        SettingsSection(title: "Legal") {
                            VStack(spacing: 0) {
                                Button(action: {
                                    if let url = URL(string: "https://eris-app.com/terms") {
                                        selectedURL = url
                                        showSafari = true
                                        HapticManager.shared.impact(.light)
                                    }
                                }) {
                                    SettingsRow(
                                        icon: "doc.text",
                                        title: "Terms of Use",
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                Button(action: {
                                    if let url = URL(string: "https://eris-app.com/privacy") {
                                        selectedURL = url
                                        showSafari = true
                                        HapticManager.shared.impact(.light)
                                    }
                                }) {
                                    SettingsRow(
                                        icon: "lock.shield",
                                        title: "Privacy Policy",
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                            }
                        }
                        
                        // About
                        SettingsSection(title: "Information") {
                            VStack(spacing: 0) {
                                Button(action: { showAbout = true }) {
                                    SettingsRow(
                                        icon: "info.circle",
                                        title: "About Eris",
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                Button(action: { showCredits = true }) {
                                    SettingsRow(
                                        icon: "heart.text.square",
                                        title: "Credits",
                                        subtitle: "Open source libraries",
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                Button(action: { showDeveloper = true }) {
                                    SettingsRow(
                                        icon: "person.crop.circle",
                                        title: "About Developer",
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                            }
                        }
                        
                        #if DEBUG
                        // Developer Options
                        SettingsSection(title: "Developer") {
                            VStack(spacing: 0) {
                                Button(action: testHaptics) {
                                    SettingsRow(
                                        icon: "waveform",
                                        title: "Test Haptics",
                                        subtitle: "Run haptic feedback test"
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                                
                                Divider()
                                    .padding(.leading, 44)
                                
                                Button(action: {
                                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                                    HapticManager.shared.warning()
                                    exit(0)
                                }) {
                                    SettingsRow(
                                        icon: "arrow.counterclockwise",
                                        title: "Reset Onboarding",
                                        subtitle: "Restart the app setup process",
                                        iconColor: .red
                                    )
                                }
                                .buttonStyle(SettingsRowButtonStyle())
                            }
                        }
                        #endif
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showCredits) {
            CreditsView()
        }
        .sheet(isPresented: $showDeveloper) {
            AboutDeveloperView()
        }
        .sheet(isPresented: $showSafari) {
            if let url = selectedURL {
                SafariView(url: url)
            }
        }
    }
    
    #if DEBUG
    private func testHaptics() {
        let haptics: [(String, () -> Void)] = [
            ("Light", { HapticManager.shared.impact(.light) }),
            ("Medium", { HapticManager.shared.impact(.medium) }),
            ("Heavy", { HapticManager.shared.impact(.heavy) }),
            ("Success", { HapticManager.shared.notification(.success) }),
            ("Warning", { HapticManager.shared.notification(.warning) }),
            ("Error", { HapticManager.shared.notification(.error) }),
            ("Selection", { HapticManager.shared.selection() }),
            ("Bounce", { HapticManager.shared.bounce() }),
            ("Processing", { HapticManager.shared.processingStart() })
        ]
        
        Task {
            for (name, haptic) in haptics {
                print("Testing haptic: \(name)")
                haptic()
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
        }
    }
    #endif
}

// MARK: - Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var iconColor: Color = .primary
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.1) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon and Name
                    VStack(spacing: 16) {
                        Image("AppIconNoBg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("Eris.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Chat with AI privately")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Eris")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Eris is a private AI chat application that runs entirely on your device. Named after the dwarf planet that challenged our understanding of the solar system, Eris challenges the notion that AI must live in the cloud.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("Features")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.top)
                        
                        AboutFeatureItem(icon: "lock.shield", text: "100% private - no data leaves your device")
                        AboutFeatureItem(icon: "cpu", text: "Powered by Apple Silicon and MLX")
                        AboutFeatureItem(icon: "wifi.slash", text: "Works completely offline")
                        AboutFeatureItem(icon: "bolt", text: "Lightning fast responses")
                    }
                    .padding(.horizontal, 20)
                    
                    // Credits
                    VStack(spacing: 8) {
                        Text("Created by Ignacio Palacio")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Powered by MLX from Apple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("About")
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

struct AboutFeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}