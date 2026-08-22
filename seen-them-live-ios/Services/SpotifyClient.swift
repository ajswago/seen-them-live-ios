//
//  SpotifyClient.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/21/26.
//

import Foundation
import AuthenticationServices
import CommonCrypto

public enum CreatePlaylistStep: String, CaseIterable, Sendable {
    case notStarted = ""
    case creatingPlaylist = "Creating new playlist in your Spotify account."
    case findingSongs = "Looking up selected songs."
    case addingSongs = "Adding matched songs to newly created playlist."
    case complete = "Playlist created successfully. Enjoy listening on Spotify!"
    case failed = "Failed to create playlist."
    
    public var progress: Float {
        switch self {
        case .notStarted: return 0.0
        case .creatingPlaylist: return 0.25
        case .findingSongs: return 0.5
        case .addingSongs: return 0.75
        case .complete: return 1.0
        case .failed: return 1.0
        }
    }
}

@Observable
@MainActor
public final class SpotifyClient {
    public private(set) var accessToken: String?
    public private(set) var refreshToken: String?
    public private(set) var tokenExpiryDate: Date?
    public private(set) var spotifyUserId: String?
    
    public var createPlaylistStep: CreatePlaylistStep = .notStarted
    public var isLoading: Bool = false
    public var errorMessage: String?
    
    private let baseURL = "https://api.spotify.com/v1"
    private let tokenURL = "https://accounts.spotify.com/api/token"
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
        loadTokens()
    }
    
    private func saveTokens() {
        UserDefaults.standard.set(refreshToken, forKey: "spotify_refresh_token")
        UserDefaults.standard.set(tokenExpiryDate, forKey: "spotify_token_expiry_date")
        UserDefaults.standard.set(accessToken, forKey: "spotify_access_token")
        UserDefaults.standard.set(spotifyUserId, forKey: "spotify_user_id")
    }
    
    private func loadTokens() {
        self.refreshToken = UserDefaults.standard.string(forKey: "spotify_refresh_token")
        self.tokenExpiryDate = UserDefaults.standard.object(forKey: "spotify_token_expiry_date") as? Date
        self.accessToken = UserDefaults.standard.string(forKey: "spotify_access_token")
        self.spotifyUserId = UserDefaults.standard.string(forKey: "spotify_user_id")
    }
    
    public func checkSpotifyAuth() async {
        guard refreshToken != nil else { return }
        self.isLoading = true
        self.errorMessage = nil
        do {
            try await refreshAccessTokenIfNeeded()
            try await fetchSpotifyProfile()
        } catch {
            print("Failed to silently restore Spotify session: \(error)")
            // Clear invalid session
            self.accessToken = nil
            self.refreshToken = nil
            self.tokenExpiryDate = nil
            self.spotifyUserId = nil
            saveTokens()
        }
        self.isLoading = false
    }
    
    // MARK: - PKCE Utilities
    
    private func base64URLEncodedString(data: Data) -> String {
        var base64 = data.base64EncodedString()
        base64 = base64.replacingOccurrences(of: "+", with: "-")
        base64 = base64.replacingOccurrences(of: "/", with: "_")
        base64 = base64.replacingOccurrences(of: "=", with: "")
        return base64
    }
    
    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return base64URLEncodedString(data: Data(bytes))
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return base64URLEncodedString(data: Data(hash))
    }
    
    // MARK: - Spotify OAuth login with ASWebAuthenticationSession
    
    public func authenticate() async {
        let clientId = Configuration.spotifyClientId
        let redirectUri = Configuration.spotifyRedirectUri
        
        guard !clientId.isEmpty, !redirectUri.isEmpty else {
            self.errorMessage = "Spotify Client ID or Redirect URI is missing in Config.plist."
            return
        }
        
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        
        let scopes = "user-read-email user-read-private playlist-modify-private playlist-modify-public"
        
        var authComponents = URLComponents(string: "https://accounts.spotify.com/authorize")!
        authComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "scope", value: scopes)
        ]
        
        guard let authURL = authComponents.url else {
            self.errorMessage = "Failed to construct Spotify authorization URL."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let callbackURL: URL = try await withCheckedThrowingContinuation { continuation in
                let webSession = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: "com.swago.seenthemlive"
                ) { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let url = url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: URLError(.unknown))
                    }
                }
                
                webSession.presentationContextProvider = PresentationAnchorProvider.shared
                webSession.prefersEphemeralWebBrowserSession = false
                webSession.start()
            }
            
            guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                throw NSError(domain: "SpotifyClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authorization code not returned by Spotify."])
            }
            
            try await requestTokens(authCode: code, codeVerifier: codeVerifier)
            try await fetchSpotifyProfile()
        } catch {
            let nsError = error as NSError
            if nsError.domain == ASWebAuthenticationSessionErrorDomain && nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                // User cancelled the auth session modal - fail silently without printing error banner
                self.isLoading = false
                return
            }
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    // MARK: - Token Exchange & Refresh
    
    private func requestTokens(authCode: String, codeVerifier: String) async throws {
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "redirect_uri", value: Configuration.spotifyRedirectUri),
            URLQueryItem(name: "code_verifier", value: codeVerifier)
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        self.accessToken = tokenResponse.accessToken
        self.refreshToken = tokenResponse.refreshToken ?? self.refreshToken
        self.tokenExpiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        saveTokens()
    }
    
    public func refreshAccessTokenIfNeeded() async throws {
        guard let refreshToken = refreshToken else { return }
        
        // If token is still valid for more than 60 seconds, do not refresh
        if let expiry = tokenExpiryDate, expiry.timeIntervalSinceNow > 60 {
            return
        }
        
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Configuration.spotifyClientId),
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        request.httpBody = components.query?.data(using: .utf8)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        self.accessToken = tokenResponse.accessToken
        self.refreshToken = tokenResponse.refreshToken ?? self.refreshToken
        self.tokenExpiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
        saveTokens()
    }
    
    // MARK: - REST API Implementations
    
    private func fetchSpotifyProfile() async throws {
        try await refreshAccessTokenIfNeeded()
        guard let token = accessToken else { throw URLError(.userAuthenticationRequired) }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/me")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let profile = try JSONDecoder().decode(SpotifyProfile.self, from: data)
        self.spotifyUserId = profile.id
        saveTokens()
    }
    
    private func searchSong(artist: String, title: String) async -> String? {
        do {
            try await refreshAccessTokenIfNeeded()
            guard let token = accessToken else { return nil }
            
            var components = URLComponents(string: "\(baseURL)/search")!
            components.queryItems = [
                URLQueryItem(name: "q", value: "artist:\(artist) track:\(title)"),
                URLQueryItem(name: "type", value: "track"),
                URLQueryItem(name: "limit", value: "1")
            ]
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }
            
            let searchResponse = try JSONDecoder().decode(SpotifySongSearchResponse.self, from: data)
            return searchResponse.tracks.items?.first?.uri
        } catch {
            return nil
        }
    }
    
    private func createPlaylistOnSpotify(userId: String, name: String) async throws -> String? {
        try await refreshAccessTokenIfNeeded()
        guard let token = accessToken else { throw URLError(.userAuthenticationRequired) }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/users/\(userId)/playlists")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyDict = ["name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: [])
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return nil
        }
        
        let playlistResponse = try JSONDecoder().decode(SpotifyCreatePlaylistResponse.self, from: data)
        return playlistResponse.id
    }
    
    private func addSongsToPlaylistOnSpotify(playlistId: String, uris: [String]) async throws -> Bool {
        try await refreshAccessTokenIfNeeded()
        guard let token = accessToken else { throw URLError(.userAuthenticationRequired) }
        
        // Chunk uris in groups of 100 (Spotify API maximum per call)
        let chunks = uris.chunked(into: 100)
        
        for chunk in chunks {
            var request = URLRequest(url: URL(string: "\(baseURL)/playlists/\(playlistId)/tracks")!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let bodyDict = ["uris": chunk]
            request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: [])
            
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Orchestrated Playlist Generation
    
    public func createPlaylist(name: String, shows: [ShowModel], firestoreManager: FirestoreManager) async {
        self.createPlaylistStep = .creatingPlaylist
        self.errorMessage = nil
        
        do {
            try await refreshAccessTokenIfNeeded()
            
            // 1. Fetch user ID if missing
            if spotifyUserId == nil {
                try await fetchSpotifyProfile()
            }
            
            guard let userId = spotifyUserId else {
                self.createPlaylistStep = .failed
                self.errorMessage = "Failed to load Spotify User ID."
                return
            }
            
            // 2. Create the playlist
            guard let playlistId = try await createPlaylistOnSpotify(userId: userId, name: name) else {
                self.createPlaylistStep = .failed
                self.errorMessage = "Failed to create Spotify playlist."
                return
            }
            
            // 3. Find song URIs (Searching each show's setlist songs)
            self.createPlaylistStep = .findingSongs
            var songUris: [String] = []
            
            // Retrieve setlists matching selected shows
            let setlists = firestoreManager.userData.setlists ?? []
            for show in shows {
                guard let setlist = setlists.first(where: { $0.id == show.id }) else { continue }
                guard let artistName = setlist.artist?.name else { continue }
                guard let setGroups = setlist.sets?.set else { continue }
                
                for group in setGroups {
                    guard let songs = group.song else { continue }
                    for song in songs {
                        guard let songName = song.name, !songName.isEmpty else { continue }
                        if let uri = await searchSong(artist: artistName, title: songName) {
                            songUris.append(uri)
                        }
                    }
                }
            }
            
            // 4. Add songs to playlist
            self.createPlaylistStep = .addingSongs
            let success = try await addSongsToPlaylistOnSpotify(playlistId: playlistId, uris: songUris)
            
            if success {
                self.createPlaylistStep = .complete
            } else {
                self.createPlaylistStep = .failed
                self.errorMessage = "Failed to add matched songs to the Spotify playlist."
            }
        } catch {
            self.createPlaylistStep = .failed
            self.errorMessage = error.localizedDescription
        }
    }
}

// MARK: - UI Anchor Presentation Context Provider Helper

@MainActor
public final class PresentationAnchorProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public static let shared = PresentationAnchorProvider()
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Array Chunking Extension Helper

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
