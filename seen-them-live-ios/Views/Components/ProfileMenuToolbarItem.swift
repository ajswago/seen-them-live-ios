//
//  ProfileMenuToolbarItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ProfileMenuToolbarItem: ToolbarContent {
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    let onLogout: () -> Void
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
        self.onLogout = onLogout
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: onProfile) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                
                Button(action: onPlaylist) {
                    Label("Create Playlist", systemImage: "music.note.list")
                }
                
                Button(action: onAbout) {
                    Label("About", systemImage: "info.circle")
                }
                
                Divider()
                
                Button(role: .destructive, action: onLogout) {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
        }
    }
}
