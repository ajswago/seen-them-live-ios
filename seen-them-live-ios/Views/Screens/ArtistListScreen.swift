//
//  ArtistListScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public enum ArtistSort: String, CaseIterable, Identifiable {
    case name = "Name"
    case recent = "Recent"
    case shows = "Shows"
    
    public var id: String { rawValue }
    
    var defaultAscending: Bool {
        switch self {
        case .name: return true
        case .recent: return false
        case .shows: return false
        }
    }
}

public struct ArtistListScreen: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(FirestoreManager.self) private var firestoreManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    
    @State private var path = NavigationPath()
    @State private var sort: ArtistSort = .name
    @State private var ascending = true
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
    }
    
    private var sortedArtists: [ArtistModel] {
        let artists = firestoreManager.getArtists()
        return artists.sorted { first, second in
            switch sort {
            case .name:
                return ascending ? first.name.localizedCompare(second.name) == .orderedAscending : first.name.localizedCompare(second.name) == .orderedDescending
            case .recent:
                let firstDate = first.lastShow ?? Date.distantPast
                let secondDate = second.lastShow ?? Date.distantPast
                if firstDate == secondDate {
                    return first.name.localizedCompare(second.name) == .orderedAscending
                }
                return ascending ? firstDate < secondDate : firstDate > secondDate
            case .shows:
                if first.showCount == second.showCount {
                    return first.name.localizedCompare(second.name) == .orderedAscending
                }
                return ascending ? first.showCount < second.showCount : first.showCount > second.showCount
            }
        }
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            Group {
                if firestoreManager.isLoading && firestoreManager.getArtists().isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ArtistSortSelector(sort: $sort, ascending: $ascending, enabled: false)
                                .padding(.bottom, 8)
                            
                            ForEach(0..<3, id: \.self) { _ in
                                LoadingArtistListItemDetailed()
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if firestoreManager.getArtists().isEmpty {
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
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ArtistSortSelector(sort: $sort, ascending: $ascending, enabled: true)
                                .padding(.bottom, 8)
                            
                            ForEach(sortedArtists) { artist in
                                ArtistListItem(
                                    artistName: artist.name,
                                    lastShow: artist.lastShow,
                                    showCount: artist.showCount,
                                    showAvatar: true,
                                    onClick: {
                                        path.append(artist.id)
                                    }
                                )
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .refreshable {
                        await firestoreManager.fetchUser()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Artists")
            .toolbar {
                ProfileMenuToolbarItem(
                    onProfile: onProfile,
                    onPlaylist: onPlaylist,
                    onAbout: onAbout,
                    onLogout: { authManager.signOut() }
                )
            }
            .navigationDestination(for: String.self) { artistId in
                ArtistProfileScreen(artistMbid: artistId, path: $path)
            }
        }
    }
}

// MARK: - ArtistSortSelector Component

struct ArtistSortSelector: View {
    @Binding var sort: ArtistSort
    @Binding var ascending: Bool
    let enabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Picker("Sort By", selection: $sort) {
                ForEach(ArtistSort.allCases) { sortOption in
                    Text(sortOption.rawValue).tag(sortOption)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!enabled)
            .onChange(of: sort) { _, newValue in
                ascending = newValue.defaultAscending
            }
            
            Button(action: { ascending.toggle() }) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.body)
                    .foregroundColor(enabled ? .accentColor : Color(.placeholderText))
                    .frame(width: 44, height: 44)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(8)
            }
            .disabled(!enabled)
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ArtistListScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {}
    )
    .environment(AuthManager())
    .environment(FirestoreManager())
}
