//
//  OnboardingView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with logo
                VStack(spacing: 20) {
                    Image("AppIconNoBg")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text("Welcome to Eris")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Chat with AI models privately on your device")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 50)
                
                // Features
                VStack(spacing: 30) {
                    FeatureRow(
                        icon: "lock.shield.fill",
                        title: "100% Private",
                        description: "Your conversations never leave your device"
                    )
                    
                    FeatureRow(
                        icon: "bolt.fill",
                        title: "Lightning Fast",
                        description: "Powered by Apple Silicon and MLX framework"
                    )
                    
                    FeatureRow(
                        icon: "wifi.slash",
                        title: "Works Offline",
                        description: "No internet connection required after setup"
                    )
                    
                    FeatureRow(
                        icon: "cpu",
                        title: "Local Models",
                        description: "Download and manage AI models on device"
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Get Started button
                NavigationLink(destination: OnboardingModelSetupView(showOnboarding: $showOnboarding)) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundStyle(Color(UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(UIColor.label))
                        .cornerRadius(16)
                }
                .simultaneousGesture(TapGesture().onEnded { _ in
                    HapticManager.shared.buttonTap()
                })
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}