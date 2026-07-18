//
//  DomainModels.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/18/26.
//

import Foundation

public struct ArtistModel: Hashable, Identifiable, Sendable {
    public var id: String { mbid }
    public let mbid: String
    public let name: String
    public let lastShow: Date
    public let showCount: Int
    
    public init(mbid: String, name: String, lastShow: Date, showCount: Int) {
        self.mbid = mbid
        self.name = name
        self.lastShow = lastShow
        self.showCount = showCount
    }
}

public struct GroupedShowModel: Hashable, Identifiable, Sendable {
    public let id: String
    public let venueName: String
    public let city: String
    public let state: String
    public let date: Date
    public let artists: [String]
    
    public init(id: String, venueName: String, city: String, state: String, date: Date, artists: [String]) {
        self.id = id
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.artists = artists
    }
}

public struct ProfileModel: Hashable, Sendable {
    public let name: String
    public let email: String
    public let showCount: Int
    public let artistCount: Int
    public let venueCount: Int
    
    public init(name: String, email: String, showCount: Int, artistCount: Int, venueCount: Int) {
        self.name = name
        self.email = email
        self.showCount = showCount
        self.artistCount = artistCount
        self.venueCount = venueCount
    }
}

public struct ShowModel: Hashable, Identifiable, Sendable {
    public let id: String
    public let artist: String
    public let venueName: String
    public let city: String
    public let state: String
    public let date: Date
    public let tourName: String?
    
    public init(id: String, artist: String, venueName: String, city: String, state: String, date: Date, tourName: String? = nil) {
        self.id = id
        self.artist = artist
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.tourName = tourName
    }
}

public struct TrackModel: Hashable, Sendable {
    public let trackName: String
    public let trackNumber: Int?
    public let trackCount: Int?
    public let coverArtistName: String?
    public let isTapeTrack: Bool
    
    public init(trackName: String, trackNumber: Int? = nil, trackCount: Int? = nil, coverArtistName: String? = nil, isTapeTrack: Bool = false) {
        self.trackName = trackName
        self.trackNumber = trackNumber
        self.trackCount = trackCount
        self.coverArtistName = coverArtistName
        self.isTapeTrack = isTapeTrack
    }
}

public struct MapItemModel: Hashable, Sendable {
    public let name: String?
    public let count: Int?
    public let lat: Double?
    public let long: Double?
    
    public init(name: String?, count: Int?, lat: Double?, long: Double?) {
        self.name = name
        self.count = count
        self.lat = lat
        self.long = long
    }
}
