//
//  seen_them_live_iosTests.swift
//  seen-them-live-iosTests
//
//  Created by Anthony Swago on 7/17/26.
//

import Testing
import Foundation
@testable import seen_them_live_ios

struct seen_them_live_iosTests {

    @Test func testCommaSeparatedStringFormatting() async throws {
        // Test with empty array
        let emptyArray: [String] = []
        #expect(emptyArray.formatCommaSeparatedString(maxDisplayed: 2) == "")
        
        // Test with single element
        let single = ["Metallica"]
        #expect(single.formatCommaSeparatedString(maxDisplayed: 2) == "Metallica")
        
        // Test with exact maxDisplayed elements (should be sorted alphabetically)
        let exact = ["Slayer", "Anthrax"]
        #expect(exact.formatCommaSeparatedString(maxDisplayed: 2) == "Anthrax, Slayer")
        
        // Test with elements exceeding maxDisplayed
        let exceeded = ["Slayer", "Testament", "Anthrax", "Megadeth"]
        // Sorted: Anthrax, Megadeth, Slayer, Testament
        // Prefix(2): Anthrax, Megadeth
        // Count(4) > 2 -> appends " +2"
        #expect(exceeded.formatCommaSeparatedString(maxDisplayed: 2) == "Anthrax, Megadeth +2")
    }

    @Test func testDateFormattingForDisplay() async throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 16
        components.calendar = Calendar(identifier: .gregorian)
        
        guard let date = components.date else {
            Issue.record("Failed to create test date")
            return
        }
        
        let formatted = date.formatForDisplay()
        
        // DateFormatter with medium style and US locale should produce "Aug 16, 2026"
        // Let's verify that the output string contains the key date components
        #expect(formatted.contains("2026"))
        #expect(formatted.contains("Aug") || formatted.contains("August") || formatted.contains("8"))
    }
    
    @Test func testMapItemModelIdentifier() async throws {
        // Map item with a valid name uses name as identifier
        let itemWithName = MapItemModel(name: "Jiffy Lube Live", count: 3, lat: 38.7, long: -77.6, city: "Bristow", state: "VA")
        #expect(itemWithName.id == "Jiffy Lube Live")
        
        // Map item with nil name fallback to coordinates string
        let itemWithNilName = MapItemModel(name: nil, count: 1, lat: 38.8, long: -77.3, city: "Fairfax", state: "VA")
        #expect(itemWithNilName.id == "38.8,-77.3")
        
        // Map item with empty name fallback to coordinates string
        let itemWithEmptyName = MapItemModel(name: "", count: 1, lat: 38.9, long: -77.0, city: "Washington", state: "DC")
        #expect(itemWithEmptyName.id == "38.9,-77.0")
    }
    
    @Test func testDomainModelsInitialization() async throws {
        // ShowModel
        let date = Date()
        let show = ShowModel(id: "show123", artist: "Opeth", venueName: "The Fillmore", city: "Silver Spring", state: "MD", date: date)
        #expect(show.id == "show123")
        #expect(show.artist == "Opeth")
        #expect(show.venueName == "The Fillmore")
        #expect(show.city == "Silver Spring")
        #expect(show.state == "MD")
        #expect(show.date == date)
        
        // ArtistModel
        let artist = ArtistModel(mbid: "artist456", name: "Lamb of God", lastShow: date, showCount: 5)
        #expect(artist.id == "artist456")
        #expect(artist.name == "Lamb of God")
        #expect(artist.lastShow == date)
        #expect(artist.showCount == 5)
        
        // TrackModel
        let track = TrackModel(trackName: "Redneck", trackCount: 4, coverArtistName: "Lamb of God", isTapeTrack: false)
        #expect(track.trackName == "Redneck")
        #expect(track.trackCount == 4)
        #expect(track.coverArtistName == "Lamb of God")
        #expect(track.isTapeTrack == false)
    }
}
