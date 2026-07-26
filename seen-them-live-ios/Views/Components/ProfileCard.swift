//
//  ProfileCard.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ProfileCard: View {
    let profileName: String
    let email: String
    let showCount: Int
    let artistCount: Int
    let venueCount: Int
    
    public init(
        profileName: String,
        email: String,
        showCount: Int,
        artistCount: Int,
        venueCount: Int
    ) {
        self.profileName = profileName
        self.email = email
        self.showCount = showCount
        self.artistCount = artistCount
        self.venueCount = venueCount
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(profileName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(email)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
                .padding(.horizontal, 30)
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(showCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(showCount == 1 ? "Show" : "Shows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(artistCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(artistCount == 1 ? "Artist" : "Artists")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(venueCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(venueCount == 1 ? "Venue" : "Venues")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

public struct LoadingProfileCard: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                // Profile name skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 180, height: 24)
                    .shimmerLoading()
                
                // Email skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 14)
                    .shimmerLoading()
            }
            
            Divider()
                .padding(.horizontal, 30)
            
            HStack(spacing: 40) {
                // Stat 1 skeleton
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 10)
                }
                .shimmerLoading()
                
                // Stat 2 skeleton
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 10)
                }
                .shimmerLoading()
                
                // Stat 3 skeleton
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 20)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 50, height: 10)
                }
                .shimmerLoading()
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileCard(
            profileName: "John Doe",
            email: "john.doe@example.com",
            showCount: 67,
            artistCount: 113,
            venueCount: 29
        )
        
        LoadingProfileCard()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
