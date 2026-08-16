//
//  SearchScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI

public struct SearchScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var path = NavigationPath()
    @State private var uiState: SearchUiState = .empty
    
    private let setlistClient = SetlistClient()
    
    public init() {}
    
    enum SearchUiState: Equatable {
        case empty
        case loading
        case results([ShowModel])
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 20) {
                    SearchCard(enabled: uiState != .loading) { searchTerms in
                        Task {
                            await performSearch(terms: searchTerms)
                        }
                    }
                    
                    Text("Results")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    switch uiState {
                    case .empty:
                        Text("Perform a search to see results")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    case .loading:
                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                LoadingShowListItem()
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    case .results(let shows):
                        if shows.isEmpty {
                            Text("No results found.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(shows) { show in
                                    ShowListItem(
                                        artistName: show.artist,
                                        venueName: show.venueName,
                                        city: show.city,
                                        state: show.state,
                                        date: show.date,
                                        onClick: {
                                            path.append(show.id)
                                        }
                                    )
                                    Divider()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: String.self) { showId in
                ShowDetailScreen(showId: showId, path: $path)
            }
        }
    }
    
    private func performSearch(terms: SearchTerms) async {
        uiState = .loading
        do {
            let response = try await setlistClient.getSearchResults(searchTerms: terms)
            let parsedShows = (response.setlist ?? []).map { $0.toShowModel() }
            uiState = .results(parsedShows)
        } catch {
            print("Error performing search: \(error)")
            uiState = .results([])
        }
    }
}

#Preview {
    SearchScreen()
}
