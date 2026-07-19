//
//  seen_them_live_iosApp.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/17/26.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct seen_them_live_iosApp: App {
    
    init() {
        // ✅ CRITICAL INITIALIZATION ORDER:
        // FirebaseApp.configure() MUST be called in init() before any Firebase-dependent state objects are created.
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("⚠️ GoogleService-Info.plist not found in bundle. Please add GoogleService-Info.plist to enable Firebase features.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // Handles Google Sign-In redirect URLs
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
