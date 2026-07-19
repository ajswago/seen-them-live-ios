//
//  SetlistClient.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/19/26.
//

import Foundation

public protocol SetlistClientProtocol: Sendable {
    func getSearchResults(searchTerms: SearchTerms, page: Int) async throws -> SetlistResponse
    func getSearchResults(date: Date, venue: String, page: Int) async throws -> SetlistResponse
    func getSetlist(id: String) async throws -> Setlist
}

public final class SetlistClient: SetlistClientProtocol, Sendable {
    private let baseURL = "https://api.setlist.fm/rest/1.0"
    private let session: URLSession
    
    private static let eventDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - API Methods
    
    public func getSearchResults(searchTerms: SearchTerms, page: Int = 1) async throws -> SetlistResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "p", value: String(page))
        ]
        
        if let artist = searchTerms.artist, !artist.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "artistName", value: artist.trimmingCharacters(in: .whitespaces)))
        }
        if let venue = searchTerms.venue, !venue.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "venueName", value: venue.trimmingCharacters(in: .whitespaces)))
        }
        if let state = searchTerms.usState, !state.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "stateCode", value: state.trimmingCharacters(in: .whitespaces)))
        }
        
        return try await fetch(endpoint: "/search/setlists", queryItems: queryItems)
    }
    
    public func getSearchResults(date: Date, venue: String, page: Int = 1) async throws -> SetlistResponse {
        let dateString = Self.eventDateFormatter.string(from: date)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "date", value: dateString),
            URLQueryItem(name: "p", value: String(page))
        ]
        
        if !venue.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "venueName", value: venue.trimmingCharacters(in: .whitespaces)))
        }
        
        return try await fetch(endpoint: "/search/setlists", queryItems: queryItems)
    }
    
    public func getSetlist(id: String) async throws -> Setlist {
        let endpoint = "/setlist/\(id)"
        return try await fetch(endpoint: endpoint, queryItems: [])
    }
    
    // MARK: - Private Request Engine
    
    private func fetch<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Configuration.setlistFmApiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        // Handle Setlist.fm 404 (Not Found) - return empty response if T is SetlistResponse
        if httpResponse.statusCode == 404 && T.self == SetlistResponse.self {
            let emptyResponse = SetlistResponse(setlist: [])
            return emptyResponse as! T
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
