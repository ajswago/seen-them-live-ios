//
//  MapScreen.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/15/26.
//

import SwiftUI
import MapKit
import CoreLocation

public struct MapScreen: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(FirestoreManager.self) private var firestoreManager
    
    let onProfile: () -> Void
    let onPlaylist: () -> Void
    let onAbout: () -> Void
    
    @State private var geocodedItems = [MapItemModel]()
    @State private var isLoadingLocations = false
    @State private var position: MapCameraPosition = .automatic
    
    public init(
        onProfile: @escaping () -> Void,
        onPlaylist: @escaping () -> Void,
        onAbout: @escaping () -> Void
    ) {
        self.onProfile = onProfile
        self.onPlaylist = onPlaylist
        self.onAbout = onAbout
    }
    
    private func pinColor(for count: Int) -> Color {
        switch count {
        case 1:
            return .blue
        case 2...4:
            return .orange
        default:
            return .red
        }
    }
    
    private func pinSize(for count: Int) -> CGFloat {
        switch count {
        case 1:
            return 14
        case 2...4:
            return 20
        default:
            return 26
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoadingLocations || firestoreManager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Resolving venue coordinates...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if geocodedItems.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "map.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 16)
                        Text("No Venues Mapped")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Add shows you've seen to populate the map.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                } else {
                    Map(position: $position) {
                        ForEach(geocodedItems) { item in
                            if let lat = item.lat, let long = item.long {
                                let count = item.count ?? 0
                                Annotation(
                                    item.name ?? "Venue",
                                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)
                                ) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "music.note.house.fill")
                                            .font(.system(size: pinSize(for: count)))
                                            .foregroundColor(pinColor(for: count))
                                            .padding(6)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                                        
                                        Text("\(item.name ?? "") (\(count))")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(.systemBackground).opacity(0.85))
                                            .cornerRadius(4)
                                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .toolbar {
                ProfileMenuToolbarItem(
                    onProfile: onProfile,
                    onPlaylist: onPlaylist,
                    onAbout: onAbout,
                    onLogout: { authManager.signOut() }
                )
            }
            .task {
                await loadLocations()
            }
        }
    }
    
    private func loadLocations() async {
        let items = firestoreManager.getMapItems()
        guard !items.isEmpty else {
            self.geocodedItems = []
            return
        }
        
        isLoadingLocations = true
        var geocoded = [MapItemModel]()
        for item in items {
            guard let name = item.name, let cityLat = item.lat, let cityLong = item.long else {
                geocoded.append(item)
                continue
            }
            
            // Build a complete address search query
            var query = name
            if let city = item.city, !city.isEmpty {
                query += ", \(city)"
            }
            if let state = item.state, !state.isEmpty {
                query += ", \(state)"
            }
            
            // Protect against geocoder rate limit (increased to 500ms to prevent Code 8 throttling errors)
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Instantiate a fresh CLGeocoder for each search query to avoid overlapping task collisions
            let geocoder = CLGeocoder()
            var resolvedCoordinate: CLLocationCoordinate2D? = nil
            
            // Stage 1: Try geocoding full query restricted to 50km radius centered on city coords
            if cityLat != 0.0 || cityLong != 0.0 {
                let region = CLCircularRegion(
                    center: CLLocationCoordinate2D(latitude: cityLat, longitude: cityLong),
                    radius: 50_000,
                    identifier: name
                )
                do {
                    let placemarks = try await geocoder.geocodeAddressString(query, in: region)
                    resolvedCoordinate = placemarks.first?.location?.coordinate
                } catch {
                    // Suppress and try fallback
                }
            }
            
            // Stage 2: Fallback to geocoding full query globally (no region restriction)
            if resolvedCoordinate == nil {
                do {
                    let placemarks = try await geocoder.geocodeAddressString(query)
                    resolvedCoordinate = placemarks.first?.location?.coordinate
                } catch {
                    // Suppress and try fallback
                }
            }
            
            // Stage 3: Fallback to geocoding just venue name globally
            if resolvedCoordinate == nil {
                do {
                    let placemarks = try await geocoder.geocodeAddressString(name)
                    resolvedCoordinate = placemarks.first?.location?.coordinate
                } catch {
                    // Suppress and use city coordinates fallback
                }
            }
            
            if resolvedCoordinate == nil {
                print("MapScreen: Precise geocoding unavailable for venue '\(name)'. Falling back to city coordinates (\(cityLat), \(cityLong)).")
            }
            
            if let coordinate = resolvedCoordinate {
                geocoded.append(MapItemModel(
                    name: name,
                    count: item.count,
                    lat: coordinate.latitude,
                    long: coordinate.longitude,
                    city: item.city,
                    state: item.state
                ))
            } else {
                // Final fallback: Use city coordinates
                geocoded.append(item)
            }
        }
        
        self.geocodedItems = geocoded
        isLoadingLocations = false
        position = .automatic
    }
}

#Preview {
    MapScreen(
        onProfile: {},
        onPlaylist: {},
        onAbout: {}
    )
    .environment(AuthManager())
    .environment(FirestoreManager())
}
