//
//  ShowDetailScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct ShowDetailScreen: View {
    let showId: String
    @Binding var path: NavigationPath
    
    @Environment(FirestoreManager.self) private var firestoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var setlist: Setlist?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @State private var relatedShows: [ShowModel] = []
    @State private var isSearchingRelated = false
    @State private var showRelatedSheet = false
    
    @State private var showConfirmation = false
    @State private var isTogglingSave = false
    
    private let setlistClient = SetlistClient()
    
    public init(showId: String, path: Binding<NavigationPath>) {
        self.showId = showId
        self._path = path
    }
    
    private var isSaved: Bool {
        firestoreManager.userData.setlists?.contains(where: { $0.id == showId }) ?? false
    }
    
    private var showModel: ShowModel? {
        if let current = setlist {
            return current.toShowModel()
        }
        return nil
    }
    
    private var linkedShows: [ShowModel] {
        guard let currentSetlist = setlist else { return [] }
        return getLinkedShowsInProfile(for: currentSetlist)
    }
    
    private var mainTracks: [TrackModel] {
        guard let sets = setlist?.sets?.set else { return [] }
        let nonEncoreSets = sets.filter { ($0.encore ?? 0) <= 0 }
        let nonTapeSongs = nonEncoreSets.flatMap { $0.song?.filter { !($0.tape ?? false) } ?? [] }
        
        var tracks: [TrackModel] = []
        for set in nonEncoreSets {
            guard let songs = set.song else { continue }
            for song in songs {
                let isTape = song.tape ?? false
                let trackNumber: Int?
                if isTape {
                    trackNumber = nil
                } else if let index = nonTapeSongs.firstIndex(of: song) {
                    trackNumber = index + 1
                } else {
                    trackNumber = nil
                }
                
                tracks.append(TrackModel(
                    trackName: song.name ?? "",
                    trackNumber: trackNumber,
                    coverArtistName: song.cover?.name,
                    isTapeTrack: isTape
                ))
            }
        }
        return tracks
    }
    
    private var encoreTracks: [TrackModel] {
        guard let sets = setlist?.sets?.set else { return [] }
        let encoreSets = sets.filter { ($0.encore ?? 0) > 0 }
        
        var tracks: [TrackModel] = []
        for set in encoreSets {
            guard let songs = set.song else { continue }
            for (index, song) in songs.enumerated() {
                tracks.append(TrackModel(
                    trackName: song.name ?? "",
                    trackNumber: index + 1,
                    coverArtistName: song.cover?.name,
                    isTapeTrack: song.tape ?? false
                ))
            }
        }
        return tracks
    }
    
    public var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Group {
                if isLoading {
                    ScrollView {
                        VStack(spacing: 24) {
                            LoadingShowCard()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                sectionHeader("Also at this show")
                                ForEach(0..<2, id: \.self) { _ in
                                    LoadingArtistListItemDetailed()
                                    Divider()
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                sectionHeader("Setlist")
                                ForEach(0..<4, id: \.self) { _ in
                                    LoadingTrackListItemNumbered()
                                    Divider()
                                }
                            }
                        }
                        .padding()
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        Text("Error Loading Show")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Button("Retry") {
                            Task {
                                await loadShow()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if let show = showModel {
                    ScrollView {
                        VStack(spacing: 24) {
                            ShowCard(
                                artistName: show.artist,
                                venueName: show.venueName,
                                city: show.city,
                                state: show.state,
                                date: show.date,
                                tourName: show.tourName
                            )
                            
                            VStack(alignment: .leading, spacing: 0) {
                                sectionHeader("Also at this show")
                                    .padding(.bottom, 8)
                                
                                ForEach(linkedShows) { linked in
                                    ArtistListItem(
                                        artistName: linked.artist,
                                        onClick: {
                                            path.append(linked.id)
                                        }
                                    )
                                    Divider()
                                }
                                
                                FindMoreListItem(enabled: true) {
                                    showRelatedSheet = true
                                    Task {
                                        await findRelatedShows()
                                    }
                                }
                                Divider()
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                sectionHeader("Setlist")
                                    .padding(.bottom, 8)
                                
                                if mainTracks.isEmpty {
                                    Text("No tracks listed.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                } else {
                                    ForEach(mainTracks, id: \.self) { track in
                                        TrackListItem(
                                            trackName: track.trackName,
                                            trackNumber: track.trackNumber,
                                            coverArtistName: track.coverArtistName,
                                            isTapeTrack: track.isTapeTrack
                                        )
                                        Divider()
                                    }
                                }
                            }
                            
                            if !encoreTracks.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    sectionHeader("Encore")
                                        .padding(.bottom, 8)
                                    
                                    ForEach(encoreTracks, id: \.self) { track in
                                        TrackListItem(
                                            trackName: track.trackName,
                                            trackNumber: track.trackNumber,
                                            coverArtistName: track.coverArtistName,
                                            isTapeTrack: track.isTapeTrack
                                        )
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            if isTogglingSave {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showConfirmation = true }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                }
                .disabled(isLoading || setlist == nil)
            }
        }
        .alert("Confirm", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button(isSaved ? "Remove" : "Add", role: isSaved ? .destructive : nil) {
                Task {
                    await toggleSave()
                }
            }
        } message: {
            Text(isSaved ? "This show will be removed from your user profile. Do you wish to continue?" : "This show will be added to your user profile. Do you wish to continue?")
        }
        .sheet(isPresented: $showRelatedSheet) {
            NavigationStack {
                Group {
                    if isSearchingRelated {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Searching Setlist.fm...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if relatedShows.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.secondary)
                            Text("No other artists found.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        List {
                            ForEach(relatedShows) { show in
                                ShowListItem(
                                    artistName: show.artist,
                                    venueName: show.venueName,
                                    city: show.city,
                                    state: show.state,
                                    date: show.date,
                                    onClick: {
                                        showRelatedSheet = false
                                        path.append(show.id)
                                    }
                                )
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Also Performing")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showRelatedSheet = false
                        }
                    }
                }
            }
        }
        .task {
            await loadShow()
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
    
    private func loadShow() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let saved = firestoreManager.userData.setlists?.first(where: { $0.id == showId }) {
                self.setlist = saved
            } else {
                let fetched = try await setlistClient.getSetlist(id: showId)
                self.setlist = fetched
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func toggleSave() async {
        guard let current = setlist else { return }
        isTogglingSave = true
        
        if isSaved {
            await firestoreManager.removeShow(showId: showId)
        } else {
            await firestoreManager.saveShow(setlist: current)
        }
        
        // Reload show state from local cache
        if let saved = firestoreManager.userData.setlists?.first(where: { $0.id == showId }) {
            self.setlist = saved
        }
        
        isTogglingSave = false
    }
    
    private func findRelatedShows() async {
        guard let current = setlist,
              let date = current.eventDate.map({ parseEventDate($0) }),
              let venue = current.venue?.name else { return }
        
        isSearchingRelated = true
        relatedShows = []
        
        do {
            let response = try await setlistClient.getSearchResults(date: date, venue: venue)
            let filtered = (response.setlist ?? []).filter { $0.id != showId }
            self.relatedShows = filtered.map { $0.toShowModel() }
        } catch {
            print("Error finding related shows: \(error)")
        }
        
        isSearchingRelated = false
    }
    
    private func getLinkedShowsInProfile(for current: Setlist) -> [ShowModel] {
        guard let eventDate = current.eventDate,
              let venueId = current.venue?.id,
              let currentArtistMbid = current.artist?.mbid else {
            return []
        }
        
        let linked = firestoreManager.userData.setlists?.filter { saved in
            saved.eventDate == eventDate &&
            saved.venue?.id == venueId &&
            saved.artist?.mbid != currentArtistMbid
        } ?? []
        
        return linked.map { $0.toShowModel() }
    }
    
    private func parseEventDate(_ dateString: String?) -> Date {
        guard let dateString = dateString else { return Date() }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString) ?? Date()
    }
}

// MARK: - FindMoreListItem Custom Component

struct FindMoreListItem: View {
    let enabled: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.body)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text("Find More")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1.0 : 0.5)
    }
}

// MARK: - Setlist Extension to convert to ShowModel

extension Setlist {
    func toShowModel() -> ShowModel {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let parsedDate = eventDate.flatMap { formatter.date(from: $0) } ?? Date()
        let stateCode = venue?.city?.stateCode ?? venue?.city?.state ?? ""
        
        return ShowModel(
            id: id ?? "",
            artist: artist?.name ?? "",
            venueName: venue?.name ?? "",
            city: venue?.city?.name ?? "",
            state: stateCode,
            date: parsedDate,
            tourName: tour?.name
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()
        var body: some View {
            NavigationStack {
                ShowDetailScreen(showId: "63ba767b", path: $path)
                    .environment(FirestoreManager())
            }
        }
    }
    return PreviewWrapper()
}
