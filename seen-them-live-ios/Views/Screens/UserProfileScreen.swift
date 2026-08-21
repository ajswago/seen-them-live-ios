//
//  UserProfileScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct UserProfileScreen: View {
    @Environment(FirestoreManager.self) private var firestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var path = NavigationPath()
    
    public init() {}
    
    private var topArtists: [ArtistModel] {
        let artists = firestoreManager.getArtists()
        let sorted = artists.sorted { first, second in
            if first.showCount == second.showCount {
                return first.name.localizedCompare(second.name) == .orderedAscending
            }
            return first.showCount > second.showCount
        }
        return Array(sorted.prefix(10))
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if firestoreManager.isLoading && firestoreManager.getArtists().isEmpty {
                            LoadingProfileCard()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                sectionHeader("Top Artists")
                                ForEach(0..<4, id: \.self) { _ in
                                    LoadingArtistListItemDetailed()
                                    Divider()
                                }
                            }
                        } else {
                            let profile = firestoreManager.getProfile()
                            ProfileCard(
                                profileName: profile.name,
                                email: profile.email,
                                showCount: profile.showCount,
                                artistCount: profile.artistCount,
                                venueCount: profile.venueCount
                            )
                            
                            VStack(alignment: .leading, spacing: 0) {
                                sectionHeader("Top Artists")
                                    .padding(.bottom, 8)
                                
                                ForEach(topArtists) { artist in
                                    ArtistListItem(
                                        artistName: artist.name,
                                        lastShow: artist.lastShow,
                                        showCount: artist.showCount,
                                        showAvatar: true,
                                        onClick: {
                                            path.append(ArtistRoute.artistProfile(mbid: artist.id))
                                        }
                                    )
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding()
                }
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
            .navigationDestination(for: ArtistRoute.self) { route in
                switch route {
                case .artistProfile(let mbid):
                    ArtistProfileScreen(artistMbid: mbid, path: $path)
                case .showDetail(let showId):
                    ShowDetailScreen(showId: showId, path: $path)
                }
            }
            .navigationDestination(for: String.self) { showId in
                ShowDetailScreen(showId: showId, path: $path)
            }
        }
    }
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    UserProfileScreen()
        .environment(FirestoreManager())
}
