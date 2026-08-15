//
//  MapScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct MapScreen: View {
    @Environment(AuthManager.self) private var authManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "map.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Text("Map Screen")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Interactive venue pins map will be implemented in Phase 4.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Map")
            .toolbar {
                ProfileMenuToolbarItem(
                    onProfile: onProfile,
                    onPlaylist: onPlaylist,
                    onAbout: onAbout,
                    onLogout: { authManager.signOut() }
                )
            }
        }
    }
}

#Preview {
    MapScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {}
    )
    .environment(AuthManager())
}
