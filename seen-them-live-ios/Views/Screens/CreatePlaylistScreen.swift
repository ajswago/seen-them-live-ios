//
//  CreatePlaylistScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct CreatePlaylistScreen: View {
    @Environment(FirestoreManager.self) private var firestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var spotifyClient = SpotifyClient()
    @State private var playlistName: String = "Seen Them Live Playlist"
    @State private var selections: [String: Bool] = [:] // key: show.id, value: Bool
    
    public init() {}
    
    struct GroupedKey: Hashable {
        let date: Date
        let venueName: String
        let city: String
        let state: String
    }
    
    private var groupedShows: [GroupedKey: [ShowModel]] {
        let shows = firestoreManager.getShows()
        return Dictionary(grouping: shows) { show in
            GroupedKey(date: show.date, venueName: show.venueName, city: show.city, state: show.state)
        }
    }
    
    private var sortedGroupKeys: [GroupedKey] {
        groupedShows.keys.sorted { $0.date > $1.date }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if spotifyClient.isLoading && spotifyClient.spotifyUserId == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Connecting to Spotify...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if spotifyClient.spotifyUserId == nil {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        
                        Text("Connect to Spotify")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Generate Spotify playlists based on your concert history. Connect your Spotify account to get started.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            Task {
                                await spotifyClient.authenticate()
                            }
                        }) {
                            Text("Connect Spotify")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                        
                        if let error = spotifyClient.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            CreatePlaylistCard(
                                playlistName: $playlistName,
                                enabled: spotifyClient.createPlaylistStep == .notStarted,
                                onCreate: {
                                    Task {
                                        await startPlaylistGeneration()
                                    }
                                }
                            )
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Shows")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.horizontal)
                                
                                Text("Check the shows and artists you want to include in this playlist.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                            
                            VStack(spacing: 0) {
                                ForEach(sortedGroupKeys, id: \.self) { key in
                                    let groupShows = groupedShows[key] ?? []
                                    SelectableShowGroupRow(
                                        key: key,
                                        groupShows: groupShows,
                                        selections: $selections
                                    )
                                    
                                    Divider()
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                        }
                        .padding(.vertical)
                    }
                }
                
                // Progress Dialog Overlay
                if spotifyClient.createPlaylistStep != .notStarted {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 20) {
                        Text("Create Playlist")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top)
                        
                        ProgressView(value: spotifyClient.createPlaylistStep.progress)
                            .progressViewStyle(.linear)
                            .tint(.accentColor)
                            .padding(.horizontal)
                        
                        Text(spotifyClient.createPlaylistStep.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(minHeight: 44)
                            .padding(.horizontal)
                        
                        if let error = spotifyClient.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        
                        Divider()
                        
                        HStack(spacing: 0) {
                            if spotifyClient.createPlaylistStep == .failed {
                                Button("Cancel") {
                                    withAnimation {
                                        spotifyClient.createPlaylistStep = .notStarted
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                
                                Divider()
                                
                                Button("Retry") {
                                    Task {
                                        await startPlaylistGeneration()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .fontWeight(.bold)
                            } else if spotifyClient.createPlaylistStep == .complete {
                                Button("Dismiss") {
                                    withAnimation {
                                        spotifyClient.createPlaylistStep = .notStarted
                                    }
                                    dismiss()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .fontWeight(.bold)
                            } else {
                                Spacer()
                                    .frame(height: 44)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Create Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await spotifyClient.checkSpotifyAuth()
            }
        }
    }
    
    private func startPlaylistGeneration() async {
        let shows = firestoreManager.getShows()
        let selectedShows = shows.filter { selections[$0.id] == true }
        
        withAnimation {
            spotifyClient.createPlaylistStep = .creatingPlaylist
        }
        
        await spotifyClient.createPlaylist(
            name: playlistName,
            shows: selectedShows,
            firestoreManager: firestoreManager
        )
    }
}

struct SelectableShowGroupRow: View {
    let key: CreatePlaylistScreen.GroupedKey
    let groupShows: [ShowModel]
    @Binding var selections: [String: Bool]
    
    private var artistList: [String] {
        groupShows.map { $0.artist }
    }
    
    private var groupSelections: [String: Bool] {
        var dict = [String: Bool]()
        for show in groupShows {
            dict[show.artist] = selections[show.id] ?? false
        }
        return dict
    }
    
    var body: some View {
        SelectableShowListGroup(
            venueName: key.venueName,
            city: key.city,
            state: key.state,
            date: key.date,
            artistList: artistList,
            selections: groupSelections,
            onArtistSelected: { index, selected in
                let show = groupShows[index]
                selections[show.id] = selected
            }
        )
    }
}

#Preview {
    CreatePlaylistScreen()
        .environment(FirestoreManager())
}
