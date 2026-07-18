//
//  NetworkModels.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/18/26.
//

import Foundation

public struct UserData: Codable, Hashable, Sendable {
    public var id: String?
    public var username: String?
    public var email: String?
    public var displayName: String?
    public var setlists: [Setlist]?
    
    public init(
        id: String? = nil,
        username: String? = nil,
        email: String? = nil,
        displayName: String? = nil,
        setlists: [Setlist]? = nil
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
        self.setlists = setlists
    }
}

public struct Setlist: Codable, Hashable, Sendable {
    public let artist: Artist?
    public let venue: Venue?
    public let tour: Tour?
    public let sets: Sets?
    public let info: String?
    public let url: String?
    public let id: String?
    public let versionId: String?
    public let eventDate: String?
    public let lastUpdated: String?
    
    public init(
        artist: Artist? = nil,
        venue: Venue? = nil,
        tour: Tour? = nil,
        sets: Sets? = nil,
        info: String? = nil,
        url: String? = nil,
        id: String? = nil,
        versionId: String? = nil,
        eventDate: String? = nil,
        lastUpdated: String? = nil
    ) {
        self.artist = artist
        self.venue = venue
        self.tour = tour
        self.sets = sets
        self.info = info
        self.url = url
        self.id = id
        self.versionId = versionId
        self.eventDate = eventDate
        self.lastUpdated = lastUpdated
    }
}

public struct Artist: Codable, Hashable, Sendable {
    public let mbid: String?
    public let tmid: Int?
    public let name: String?
    public let sortName: String?
    public let disambiguation: String?
    public let url: String?
    
    public init(
        mbid: String? = nil,
        tmid: Int? = nil,
        name: String? = nil,
        sortName: String? = nil,
        disambiguation: String? = nil,
        url: String? = nil
    ) {
        self.mbid = mbid
        self.tmid = tmid
        self.name = name
        self.sortName = sortName
        self.disambiguation = disambiguation
        self.url = url
    }
    
    // Quick rename support for mmid to tmid parameter name matching
    private enum CodingKeys: String, CodingKey {
        case mbid, tmid, name, sortName, disambiguation, url
    }
}

public struct Venue: Codable, Hashable, Sendable {
    public let city: City?
    public let url: String?
    public let id: String?
    public let name: String?
    
    public init(
        city: City? = nil,
        url: String? = nil,
        id: String? = nil,
        name: String? = nil
    ) {
        self.city = city
        self.url = url
        self.id = id
        self.name = name
    }
}

public struct City: Codable, Hashable, Sendable {
    public let id: String?
    public let name: String?
    public let stateCode: String?
    public let state: String?
    public let coords: Coords?
    public let country: Country?
    
    public init(
        id: String? = nil,
        name: String? = nil,
        stateCode: String? = nil,
        state: String? = nil,
        coords: Coords? = nil,
        country: Country? = nil
    ) {
        self.id = id
        self.name = name
        self.stateCode = stateCode
        self.state = state
        self.coords = coords
        self.country = country
    }
}

public struct Coords: Codable, Hashable, Sendable {
    public let long: Double?
    public let lat: Double?
    
    public init(long: Double? = nil, lat: Double? = nil) {
        self.long = long
        self.lat = lat
    }
}

public struct Country: Codable, Hashable, Sendable {
    public let code: String?
    public let name: String?
    
    public init(code: String? = nil, name: String? = nil) {
        self.code = code
        self.name = name
    }
}

public struct Tour: Codable, Hashable, Sendable {
    public let name: String?
    
    public init(name: String? = nil) {
        self.name = name
    }
}

public struct Sets: Codable, Hashable, Sendable {
    public let set: [SetlistSet]?
    
    public init(set: [SetlistSet]? = nil) {
        self.set = set
    }
}

public struct SetlistSet: Codable, Hashable, Sendable {
    public let name: String?
    public let encore: Int?
    public let song: [Song]?
    
    public init(name: String? = nil, encore: Int? = nil, song: [Song]? = nil) {
        self.name = name
        self.encore = encore
        self.song = song
    }
}

public struct Song: Codable, Hashable, Sendable {
    public let name: String?
    public let with: Artist?
    public let cover: Artist?
    public let info: String?
    public let tape: Bool?
    
    public init(
        name: String? = nil,
        with: Artist? = nil,
        cover: Artist? = nil,
        info: String? = nil,
        tape: Bool? = nil
    ) {
        self.name = name
        self.with = with
        self.cover = cover
        self.info = info
        self.tape = tape
    }
}
