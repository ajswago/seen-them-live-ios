//
//  ArtistListItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ArtistListItem: View {
    let artistName: String
    let lastShow: Date?
    let showCount: Int?
    let showAvatar: Bool
    let indent: Bool
    let onClick: (() -> Void)?
    
    public init(
        artistName: String,
        lastShow: Date? = nil,
        showCount: Int? = nil,
        showAvatar: Bool = false,
        indent: Bool = false,
        onClick: (() -> Void)? = nil
    ) {
        self.artistName = artistName
        self.lastShow = lastShow
        self.showCount = showCount
        self.showAvatar = showAvatar
        self.indent = indent
        self.onClick = onClick
    }
    
    public var body: some View {
        Button(action: { onClick?() }) {
            HStack(spacing: 16) {
                if showAvatar {
                    TextAvatar(character: artistName.first ?? "A")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(artistName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let lastShow = lastShow {
                        Text("Last Show: \(lastShow.formatForDisplay())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, indent ? 24 : 0)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if let count = showCount {
                        Text("\(count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
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

public struct LoadingArtistListItemDetailed: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            // Avatar circle skeleton
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 40, height: 40)
                .shimmerLoading()
            
            VStack(alignment: .leading, spacing: 6) {
                // Name skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 160, height: 18)
                    .shimmerLoading()
                
                // Subtitle skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
                    .shimmerLoading()
            }
            
            Spacer()
            
            // Trailing skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 20, height: 14)
                .shimmerLoading()
        }
        .padding(.vertical, 8)
    }
}

public struct LoadingArtistListItemSimple: View {
    public init() {}
    
    public var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 180, height: 18)
                .shimmerLoading()
                .padding(.leading, 24)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        ArtistListItem(
            artistName: "AC/DC",
            lastShow: Date(),
            showCount: 3,
            showAvatar: true
        )
        
        Divider()
        
        ArtistListItem(
            artistName: "Rodrigo y Gabriela",
            indent: true
        )
        
        Divider()
        
        LoadingArtistListItemDetailed()
        
        Divider()
        
        LoadingArtistListItemSimple()
    }
    .padding()
}
