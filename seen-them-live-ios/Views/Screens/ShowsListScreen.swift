//
//  ShowsListScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ShowsListScreen: View {
    @Environment(FirestoreManager.self) private var firestoreManager
    @Environment(AuthManager.self) private var authManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    let onAddShow: () -> Void
    
    @State private var path = NavigationPath()
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void,
        onAddShow: @escaping () -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
        self.onAddShow = onAddShow
    }
    
    private var groupedShows: [(Date, [ShowModel])] {
        let shows = firestoreManager.getShows()
        let grouped = Dictionary(grouping: shows, by: { $0.date })
        return grouped.map { ($0.key, $0.value) }
            .sorted { $0.0 > $1.0 }
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            Group {
                if firestoreManager.isLoading && firestoreManager.getShows().isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                LoadingExpandableShowListGroup()
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if firestoreManager.getShows().isEmpty {
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
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedShows, id: \.0) { date, showsForDate in
                                let artists = showsForDate.map { $0.artist }
                                ExpandableShowListGroup(
                                    venueName: showsForDate.first?.venueName ?? "",
                                    city: showsForDate.first?.city ?? "",
                                    state: showsForDate.first?.state ?? "",
                                    date: date,
                                    artistList: artists,
                                    onArtistClick: { index in
                                        let selectedShow = showsForDate[index]
                                        path.append(selectedShow.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await firestoreManager.fetchUser()
                    }
                }
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
            .navigationDestination(for: String.self) { showId in
                ShowDetailScreen(showId: showId, path: $path)
            }
        }
    }
}

#Preview {
    ShowsListScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {},
        onAddShow: {}
    )
    .environment(AuthManager())
    .environment(FirestoreManager())
}
