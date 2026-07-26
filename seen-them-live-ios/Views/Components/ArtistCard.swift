//
//  ArtistCard.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ArtistCard: View {
    let artistName: String
    let lastShow: Date
    let showCount: Int
    let songCount: Int
    
    public init(
        artistName: String,
        lastShow: Date,
        showCount: Int,
        songCount: Int
    ) {
        self.artistName = artistName
        self.lastShow = lastShow
        self.showCount = showCount
        self.songCount = songCount
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(artistName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
                .frame(height: 4)
            
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("Last Show: \(lastShow.formatForDisplay())")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "music.mic")
                        .foregroundColor(.secondary)
                    Text("Seen \(showCount) \(showCount == 1 ? "time" : "times")")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "music.note.list")
                        .foregroundColor(.secondary)
                    Text("\(songCount) \(songCount == 1 ? "song" : "songs") performed")
                        .font(.body)
                        .foregroundColor(.primary)
                }
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

public struct LoadingArtistCard: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Artist name skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 200, height: 24)
                .shimmerLoading()
            
            Spacer()
                .frame(height: 4)
            
            VStack(spacing: 6) {
                // Info rows skeletons
                HStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 16, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 180, height: 14)
                }
                .shimmerLoading()
                
                HStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 16, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 110, height: 14)
                }
                .shimmerLoading()
                
                HStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 16, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 140, height: 14)
                }
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

#Preview {
    VStack(spacing: 20) {
        ArtistCard(
            artistName: "Lamb of God",
            lastShow: Date(),
            showCount: 5,
            songCount: 25
        )
        
        LoadingArtistCard()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
