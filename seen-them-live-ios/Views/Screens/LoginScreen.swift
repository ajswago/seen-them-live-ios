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
                
                // Glowing Circular App Logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: "guitars.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                }
                
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
                        Image("ic_logo_google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            // Fallback if image asset is missing: show system fallback symbol
                            .opacity(UIImage(named: "ic_logo_google") != nil ? 1.0 : 0.0)
                            .overlay(
                                Image(systemName: "g.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.accentColor)
                                    .opacity(UIImage(named: "ic_logo_google") != nil ? 0.0 : 1.0)
                            )
                        
                        Text("Sign in with Google")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
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
