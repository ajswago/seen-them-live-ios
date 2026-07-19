//
//  FirestoreManager.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/19/26.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
public final class FirestoreManager {
    public private(set) var userData: UserData = UserData()
    public private(set) var isLoading: Bool = false
    public var errorMessage: String?
    
    private static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    public init() {}
    
    // MARK: - Firestore User Fetching & Subcollection Migration
    
    public func fetchUser() async {
        guard FirebaseApp.app() != nil else {
            self.errorMessage = "Firebase is not configured."
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else {
            self.userData = UserData()
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let db = Firestore.firestore()
            let userDocRef = db.collection("users").document(userId)
            
            let userSnapshot = try await userDocRef.getDocument()
            var fetchedUserData = (try? userSnapshot.data(as: UserData.self)) ?? UserData(id: userId)
            
            // Fetch subcollection setlists: /users/{userId}/setlists
            let subcollectionSnapshot = try await userDocRef.collection("setlists").getDocuments()
            let subcollectionSetlists = subcollectionSnapshot.documents.compactMap { doc -> Setlist? in
                try? doc.data(as: Setlist.self)
            }
            
            // Check for legacy migration (if root document contains nested setlists array)
            if userSnapshot.exists && userSnapshot.data()?.keys.contains("setlists") == true {
                let legacySetlists = fetchedUserData.setlists ?? []
                
                if !legacySetlists.isEmpty {
                    // Batch write setlists to subcollection in chunks of 400 (Firestore limit is 500)
                    let chunks = legacySetlists.chunked(into: 400)
                    for chunk in chunks {
                        let batch = db.batch()
                        for setlist in chunk {
                            guard let setlistId = setlist.id, !setlistId.isEmpty else { continue }
                            let setlistDocRef = userDocRef.collection("setlists").document(setlistId)
                            try batch.setData(from: setlist, forDocument: setlistDocRef)
                        }
                        try await batch.commit()
                    }
                    
                    // Delete legacy top-level setlists field from root user document
                    try await userDocRef.updateData(["setlists": FieldValue.delete()])
                    fetchedUserData.setlists = legacySetlists
                } else {
                    // Clean up empty field and use subcollection
                    try await userDocRef.updateData(["setlists": FieldValue.delete()])
                    fetchedUserData.setlists = subcollectionSetlists
                }
            } else {
                fetchedUserData.setlists = subcollectionSetlists
            }
            
            fetchedUserData.id = userId
            self.userData = fetchedUserData
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    // MARK: - Save Show
    
    public func saveShow(setlist: Setlist) async {
        guard FirebaseApp.app() != nil else { return }
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else { return }
        guard let setlistId = setlist.id, !setlistId.isEmpty else {
            self.errorMessage = "Invalid setlist ID."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let db = Firestore.firestore()
            let setlistDocRef = db.collection("users").document(userId).collection("setlists").document(setlistId)
            
            try setlistDocRef.setData(from: setlist)
            
            // Update in-memory setlists cache
            var updatedSetlists = self.userData.setlists ?? []
            updatedSetlists.removeAll { $0.id == setlistId }
            updatedSetlists.append(setlist)
            self.userData.setlists = updatedSetlists
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    // MARK: - Remove Show
    
    public func removeShow(showId: String) async {
        guard FirebaseApp.app() != nil else { return }
        guard let userId = Auth.auth().currentUser?.uid, !userId.isEmpty else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let db = Firestore.firestore()
            let setlistDocRef = db.collection("users").document(userId).collection("setlists").document(showId)
            
            try await setlistDocRef.delete()
            
            // Update in-memory setlists cache
            var updatedSetlists = self.userData.setlists ?? []
            updatedSetlists.removeAll { $0.id == showId }
            self.userData.setlists = updatedSetlists
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    // MARK: - Analytical & Aggregation Functions
    
    public func getShows() -> [ShowModel] {
        let setlists = userData.setlists ?? []
        let shows = setlists.compactMap { setlist -> ShowModel? in
            guard let id = setlist.id,
                  let artistName = setlist.artist?.name,
                  let venueName = setlist.venue?.name,
                  let city = setlist.venue?.city?.name,
                  let dateString = setlist.eventDate,
                  let date = FirestoreManager.eventDateFormatter.date(from: dateString) else {
                return nil
            }
            let state = setlist.venue?.city?.stateCode ?? setlist.venue?.city?.state ?? ""
            return ShowModel(
                id: id,
                artist: artistName,
                venueName: venueName,
                city: city,
                state: state,
                date: date,
                tourName: setlist.tour?.name
            )
        }
        return shows.sorted { $0.date > $1.date }
    }
    
    public func getArtists() -> [ArtistModel] {
        let setlists = userData.setlists ?? []
        var artistMap: [String: (name: String, showCount: Int, lastShow: Date)] = [:]
        
        for setlist in setlists {
            guard let artist = setlist.artist,
                  let artistName = artist.name,
                  let mbid = artist.mbid ?? artist.name,
                  let dateString = setlist.eventDate,
                  let date = FirestoreManager.eventDateFormatter.date(from: dateString) else {
                continue
            }
            
            if let existing = artistMap[mbid] {
                let newCount = existing.showCount + 1
                let newLastShow = max(existing.lastShow, date)
                artistMap[mbid] = (name: artistName, showCount: newCount, lastShow: newLastShow)
            } else {
                artistMap[mbid] = (name: artistName, showCount: 1, lastShow: date)
            }
        }
        
        return artistMap.map { (mbid, info) in
            ArtistModel(mbid: mbid, name: info.name, lastShow: info.lastShow, showCount: info.showCount)
        }.sorted { $0.showCount > $1.showCount }
    }
    
    public func getShowsForArtist(artistMbid: String) -> [GroupedShowModel] {
        let setlists = userData.setlists ?? []
        let matchingSetlists = setlists.filter { setlist in
            setlist.artist?.mbid == artistMbid || setlist.artist?.name == artistMbid
        }
        
        return matchingSetlists.compactMap { setlist -> GroupedShowModel? in
            guard let id = setlist.id,
                  let venueName = setlist.venue?.name,
                  let city = setlist.venue?.city?.name,
                  let dateString = setlist.eventDate,
                  let date = FirestoreManager.eventDateFormatter.date(from: dateString) else {
                return nil
            }
            
            let state = setlist.venue?.city?.stateCode ?? setlist.venue?.city?.state ?? ""
            let artistName = setlist.artist?.name ?? ""
            
            return GroupedShowModel(
                id: id,
                venueName: venueName,
                city: city,
                state: state,
                date: date,
                artists: [artistName]
            )
        }.sorted { $0.date > $1.date }
    }
    
    public func getTracksForArtist(artistMbid: String) -> [TrackModel] {
        let setlists = userData.setlists ?? []
        let matchingSetlists = setlists.filter { setlist in
            setlist.artist?.mbid == artistMbid || setlist.artist?.name == artistMbid
        }
        
        var trackCounts: [String: (count: Int, coverArtist: String?, isTape: Bool)] = [:]
        
        for setlist in matchingSetlists {
            guard let setGroups = setlist.sets?.set else { continue }
            for group in setGroups {
                guard let songs = group.song else { continue }
                for song in songs {
                    guard let songName = song.name, !songName.isEmpty else { continue }
                    let coverName = song.cover?.name
                    let isTape = song.tape ?? false
                    
                    if let existing = trackCounts[songName] {
                        trackCounts[songName] = (count: existing.count + 1, coverArtist: coverName ?? existing.coverArtist, isTape: isTape || existing.isTape)
                    } else {
                        trackCounts[songName] = (count: 1, coverArtist: coverName, isTape: isTape)
                    }
                }
            }
        }
        
        return trackCounts.map { (name, info) in
            TrackModel(
                trackName: name,
                trackNumber: nil,
                trackCount: info.count,
                coverArtistName: info.coverArtist,
                isTapeTrack: info.isTape
            )
        }.sorted { ($0.trackCount ?? 0) > ($1.trackCount ?? 0) }
    }
    
    public func getProfile() -> ProfileModel {
        let setlists = userData.setlists ?? []
        let showCount = setlists.count
        
        let uniqueArtists = Set(setlists.compactMap { $0.artist?.mbid ?? $0.artist?.name })
        let uniqueVenues = Set(setlists.compactMap { $0.venue?.id ?? $0.venue?.name })
        
        let name = userData.displayName ?? userData.username ?? "User"
        let email = userData.email ?? ""
        
        return ProfileModel(
            name: name,
            email: email,
            showCount: showCount,
            artistCount: uniqueArtists.count,
            venueCount: uniqueVenues.count
        )
    }
    
    public func getMapItems() -> [MapItemModel] {
        let setlists = userData.setlists ?? []
        var venueCounts: [String: (count: Int, lat: Double?, long: Double?)] = [:]
        
        for setlist in setlists {
            guard let venue = setlist.venue, let venueName = venue.name else { continue }
            let lat = venue.city?.coords?.lat
            let long = venue.city?.coords?.long
            
            if let existing = venueCounts[venueName] {
                venueCounts[venueName] = (count: existing.count + 1, lat: lat ?? existing.lat, long: long ?? existing.long)
            } else {
                venueCounts[venueName] = (count: 1, lat: lat, long: long)
            }
        }
        
        return venueCounts.map { (name, info) in
            MapItemModel(name: name, count: info.count, lat: info.lat, long: info.long)
        }.sorted { ($0.count ?? 0) > ($1.count ?? 0) }
    }
}

// MARK: - Array Chunking Helper

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
