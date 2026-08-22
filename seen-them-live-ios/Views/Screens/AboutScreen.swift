//
//  AboutScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                        .padding(.bottom, 30)
                    
                    Text("Seen Them Live")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 30)
                    
                    Text("Developed by Anthony Swago")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
                    Text("Version: \(appVersion) (\(currentYear))")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                        .frame(height: 160)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutScreen()
}
