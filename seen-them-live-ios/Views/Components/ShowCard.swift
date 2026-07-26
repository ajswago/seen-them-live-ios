//
//  ShowCard.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ShowCard: View {
    let artistName: String
    let venueName: String
    let city: String
    let state: String
    let date: Date
    let tourName: String?
    
    public init(
        artistName: String,
        venueName: String,
        city: String,
        state: String,
        date: Date,
        tourName: String? = nil
    ) {
        self.artistName = artistName
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.tourName = tourName
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(artistName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(date.formatForDisplay())
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            VStack(spacing: 4) {
                Text(venueName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(city), \(state)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let tourName = tourName, !tourName.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(tourName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.12))
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
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

public struct LoadingShowCard: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Artist name skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 220, height: 24)
                .shimmerLoading()
            
            // Date skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 100, height: 14)
                .shimmerLoading()
            
            Divider()
                .padding(.horizontal, 40)
            
            // Venue & Location grouped inside a sub-VStack matching ShowCard
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 180, height: 16)
                    .shimmerLoading()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 14)
                    .shimmerLoading()
            }
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

// MARK: - Date extension

public extension Date {
    func formatForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

#Preview {
    VStack(spacing: 20) {
        ShowCard(
            artistName: "DragonForce",
            venueName: "The Fillmore Silver Spring",
            city: "Silver Spring",
            state: "MD",
            date: Date(),
            tourName: "Warp Speed Warriors Tour"
        )
        
        LoadingShowCard()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
