//
//  ArtistListScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ArtistListScreen: View {
    @Environment(AuthManager.self) private var authManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    let onArtistClick: (String) -> Void
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void,
        onArtistClick: @escaping (String) -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
        self.onArtistClick = onArtistClick
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "person.3.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Text("No Artists Logged")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Your unique artists and stats will appear here after you add shows.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Artists")
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
    ArtistListScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {},
        onArtistClick: { _ in }
    )
    .environment(AuthManager())
}
