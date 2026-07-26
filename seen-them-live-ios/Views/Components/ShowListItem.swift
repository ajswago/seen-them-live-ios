//
//  ShowListItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ShowListItem: View {
    let artistName: String
    let venueName: String
    let city: String
    let state: String
    let date: Date
    let onClick: (() -> Void)?
    
    public init(
        artistName: String,
        venueName: String,
        city: String,
        state: String,
        date: Date,
        onClick: (() -> Void)? = nil
    ) {
        self.artistName = artistName
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.onClick = onClick
    }
    
    public var body: some View {
        Button(action: { onClick?() }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(city), \(state)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(artistName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(venueName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(date.formatForDisplay())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public struct LoadingShowListItem: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                // Location skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
                    .shimmerLoading()
                
                // Artist name skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 180, height: 18)
                    .shimmerLoading()
                
                // Venue name skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 14)
                    .shimmerLoading()
            }
            
            Spacer()
            
            // Date skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 70, height: 14)
                .shimmerLoading()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        ShowListItem(
            artistName: "DragonForce",
            venueName: "Revolution Concert House",
            city: "Garden City",
            state: "ID",
            date: Date(),
            onClick: {}
        )
        
        Divider()
        
        LoadingShowListItem()
    }
    .padding()
}
