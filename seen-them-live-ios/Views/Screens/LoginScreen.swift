//
//  LoginScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI
import AuthenticationServices

public struct LoginScreen: View {
    @Environment(AuthManager.self) private var authManager
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Premium background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground),
                    Color(.tertiarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App Logo
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                
                VStack(spacing: 8) {
                    Text("Seen Them Live")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Track your concert history in one place")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                    .frame(height: 24)
                
                // Google Sign In Button
                Button(action: {
                    Task {
                        await authManager.signInWithGoogle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                        
                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                }
                .disabled(authManager.isLoading)
                .padding(.horizontal, 32)
                
                // Status / Error Row
                VStack {
                    if authManager.isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                    } else if let errorMessage = authManager.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                    }
                }
                .frame(height: 60)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginScreen()
        .environment(AuthManager())
}
