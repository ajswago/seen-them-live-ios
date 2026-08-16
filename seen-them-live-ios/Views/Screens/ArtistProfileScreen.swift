//
//  ArtistProfileScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ArtistProfileScreen: View {
    let artistMbid: String
    @Binding var path: NavigationPath
    
    @Environment(FirestoreManager.self) private var firestoreManager
    @Environment(\.dismiss) private var dismiss
    
    public init(artistMbid: String, path: Binding<NavigationPath>) {
        self.artistMbid = artistMbid
        self._path = path
    }
    
    private var artist: ArtistModel? {
        firestoreManager.getArtists().first(where: { $0.id == artistMbid })
    }
    
    private var shows: [GroupedShowModel] {
        firestoreManager.getShowsForArtist(artistMbid: artistMbid)
    }
    
    private var sortedTracks: [TrackModel] {
        let tracks = firestoreManager.getTracksForArtist(artistMbid: artistMbid)
        return tracks.sorted { first, second in
            let firstCount = first.trackCount ?? 0
            let secondCount = second.trackCount ?? 0
            if firstCount == secondCount {
                return first.trackName.localizedCompare(second.trackName) == .orderedAscending
            }
            return firstCount > secondCount
        }
    }
    
    public var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    if firestoreManager.isLoading && artist == nil {
                        LoadingArtistCard()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Shows")
                            ForEach(0..<2, id: \.self) { _ in
                                LoadingGroupedShowListItem()
                                Divider()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            sectionHeader("Songs")
                            ForEach(0..<4, id: \.self) { _ in
                                LoadingTrackListItemCount()
                                Divider()
                            }
                        }
                    } else if let artist = artist {
                        ArtistCard(
                            artistName: artist.name,
                            lastShow: artist.lastShow,
                            showCount: shows.count,
                            songCount: sortedTracks.count
                        )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            sectionHeader("Shows")
                                .padding(.bottom, 8)
                            
                            ForEach(shows) { show in
                                GroupedShowListItem(
                                    venueName: show.venueName,
                                    city: show.city,
                                    state: show.state,
                                    artistList: show.artists,
                                    date: show.date,
                                    onClick: {
                                        // Push ShowDetailScreen using its ID
                                        path.append(ArtistRoute.showDetail(id: show.id))
                                    }
                                )
                                Divider()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            sectionHeader("Songs")
                                .padding(.bottom, 8)
                            
                            if sortedTracks.isEmpty {
                                Text("No songs logged.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                            } else {
                                ForEach(sortedTracks, id: \.self) { track in
                                    TrackListItem(
                                        trackName: track.trackName,
                                        trackCount: track.trackCount,
                                        coverArtistName: track.coverArtistName
                                    )
                                    Divider()
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("Artist Not Found")
                                .font(.headline)
                            Button("Go Back") {
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Artist")
        .navigationBarTitleDisplayMode(.inline)
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
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()
        var body: some View {
            NavigationStack {
                ArtistProfileScreen(artistMbid: "Lamb of God", path: $path)
                    .environment(FirestoreManager())
            }
        }
    }
    return PreviewWrapper()
}
