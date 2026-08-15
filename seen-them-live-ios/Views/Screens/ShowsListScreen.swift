//
//  ShowsListScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ShowsListScreen: View {
    @Environment(AuthManager.self) private var authManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    let onAddShow: () -> Void
    let onShowClick: (String) -> Void
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void,
        onAddShow: @escaping () -> Void,
        onShowClick: @escaping (String) -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
        self.onAddShow = onAddShow
        self.onShowClick = onShowClick
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "music.note.list")
                    .font(.system(size: 64))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                Text("No Shows Added Yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Tap '+' to search and add setlists you've seen live.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Shows")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onAddShow) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
                
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
    ShowsListScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {},
        onAddShow: {},
        onShowClick: { _ in }
    )
    .environment(AuthManager())
}
