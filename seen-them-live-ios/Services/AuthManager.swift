//
//  AuthManager.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/19/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn

@Observable
@MainActor
public final class AuthManager {
    public private(set) var user: User?
    public private(set) var isAuthenticated: Bool = false
    public private(set) var isLoading: Bool = false
    public var errorMessage: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    public init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Auth Listener
    
    private func setupAuthStateListener() {
        // Safe check to verify Firebase is configured before adding listener
        guard FirebaseApp.app() != nil else { return }
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.user = user
                self?.isAuthenticated = (user != nil)
            }
        }
    }
    
    // MARK: - Google Sign-In
    
    public func signInWithGoogle() async {
        guard FirebaseApp.app() != nil else {
            self.errorMessage = "Firebase is not configured. Please add GoogleService-Info.plist."
            return
        }
        
        guard let presentingViewController = getRootViewController() else {
            self.errorMessage = "Unable to locate root view controller for Google Sign-In presentation."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing ID token from Google user."])
            }
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            self.isAuthenticated = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    // MARK: - Sign Out
    
    public func signOut() {
        guard FirebaseApp.app() != nil else { return }
        
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Presentation Helper
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topViewController = rootViewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }
        return topViewController
    }
}
