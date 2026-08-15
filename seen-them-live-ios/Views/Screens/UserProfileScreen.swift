//
//  UserProfileScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct UserProfileScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Text("User Profile")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Stats aggregation and profile info will be loaded here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Profile")
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
    UserProfileScreen()
}
