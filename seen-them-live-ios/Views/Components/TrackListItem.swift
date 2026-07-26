//
//  TrackListItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct TrackListItem: View {
    let trackName: String
    let trackNumber: Int?
    let trackCount: Int?
    let coverArtistName: String?
    let isTapeTrack: Bool
    
    public init(
        trackName: String,
        trackNumber: Int? = nil,
        trackCount: Int? = nil,
        coverArtistName: String? = nil,
        isTapeTrack: Bool = false
    ) {
        self.trackName = trackName
        self.trackNumber = trackNumber
        self.trackCount = trackCount
        self.coverArtistName = coverArtistName
        self.isTapeTrack = isTapeTrack
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if let trackNumber = trackNumber {
                Text("\(trackNumber).")
                    .font(.body)
                    .foregroundColor(isTapeTrack ? .secondary.opacity(0.38) : .secondary)
                    .frame(width: 24, alignment: .trailing)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(trackName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isTapeTrack ? .primary.opacity(0.38) : .primary)
                
                if let coverArtistName = coverArtistName {
                    Text("(Cover of \(coverArtistName))")
                        .font(.caption)
                        .foregroundColor(isTapeTrack ? .secondary.opacity(0.38) : .secondary)
                }
            }
            
            Spacer()
            
            if let count = trackCount {
                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(isTapeTrack ? .secondary.opacity(0.38) : .secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

public struct LoadingTrackListItemNumbered: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Track number skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 16, height: 16)
                .shimmerLoading()
            
            // Track name skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 200, height: 16)
                .shimmerLoading()
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

public struct LoadingTrackListItemCount: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 12) {
            // Track name skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 220, height: 16)
                .shimmerLoading()
            
            Spacer()
            
            // Count skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 16, height: 14)
                .shimmerLoading()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        TrackListItem(
            trackName: "Fury of the Storm",
            trackNumber: 1
        )
        
        Divider()
        
        TrackListItem(
            trackName: "It's a Long Way to the Top",
            coverArtistName: "AC/DC",
            isTapeTrack: true
        )
        
        Divider()
        
        TrackListItem(
            trackName: "Now You've Got Something to Die For",
            trackCount: 5
        )
        
        Divider()
        
        LoadingTrackListItemNumbered()
        
        Divider()
        
        LoadingTrackListItemCount()
    }
    .padding()
}
