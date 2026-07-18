//
//  Configuration.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/17/26.
//

import Foundation

enum Configuration {
    private static var plistDict: [String: Any]? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return plist
    }
    
    static var setlistFmApiKey: String {
        return plistDict?["SETLIST_FM_API_KEY"] as? String ?? ""
    }
    
    static var spotifyClientId: String {
        return plistDict?["SPOTIFY_CLIENT_ID"] as? String ?? ""
    }
    
    static var spotifyRedirectUri: String {
        return plistDict?["SPOTIFY_REDIRECT_URI"] as? String ?? ""
    }
}
