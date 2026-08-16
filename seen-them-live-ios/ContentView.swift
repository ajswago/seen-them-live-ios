//
//  ContentView.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/17/26.
//

import SwiftUI

public struct ContentView: View {
    @State private var authManager = AuthManager()
    @State private var firestoreManager = FirestoreManager()
    @State private var selectedTab = 0
    @State private var activeSheet: ActiveSheet?
    
    public enum ActiveSheet: Identifiable, Hashable {
        case profile
        case playlist
        case about
        case addShow
        
        public var id: Self { self }
    }
    
    public init() {}
    
    public var body: some View {
        Group {
            if authManager.isAuthenticated {
                TabView(selection: $selectedTab) {
                    ShowsListScreen(
                        onProfile: { activeSheet = .profile },
                        onPlaylist: { activeSheet = .playlist },
                        onAbout: { activeSheet = .about },
                        onAddShow: { activeSheet = .addShow }
                    )
                    .tabItem {
                        Label("Shows", systemImage: "clock.fill")
                    }
                    .tag(0)
                    
                    ArtistListScreen(
                        onProfile: { activeSheet = .profile },
                        onPlaylist: { activeSheet = .playlist },
                        onAbout: { activeSheet = .about }
                    )
                    .tabItem {
                        Label("Artists", systemImage: "person.3.fill")
                    }
                    .tag(1)
                    
                    MapScreen(
                        onProfile: { activeSheet = .profile },
                        onPlaylist: { activeSheet = .playlist },
                        onAbout: { activeSheet = .about }
                    )
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(2)
                }
                .sheet(item: $activeSheet) { sheet in
                    switch sheet {
                    case .profile:
                        UserProfileScreen()
                    case .playlist:
                        CreatePlaylistScreen()
                    case .about:
                        AboutScreen()
                    case .addShow:
                        SearchScreen()
                    }
                }
            } else {
                LoginScreen()
            }
        }
        .environment(authManager)
        .environment(firestoreManager)
        .task(id: authManager.isAuthenticated) {
            if authManager.isAuthenticated {
                await firestoreManager.fetchUser()
            }
        }
    }
}

#Preview {
    ContentView()
}
