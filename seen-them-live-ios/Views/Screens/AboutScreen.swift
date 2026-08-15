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
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Text("About")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Seen Them Live version 1.0.0\nDeveloped in Swift using SwiftUI.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
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
