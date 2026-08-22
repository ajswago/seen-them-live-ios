//
//  SelectableArtistListItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct SelectableArtistListItem: View {
    let artistName: String
    let checked: Bool
    let onCheckedChange: (Bool) -> Void
    
    public init(
        artistName: String,
        checked: Bool,
        onCheckedChange: @escaping (Bool) -> Void
    ) {
        self.artistName = artistName
        self.checked = checked
        self.onCheckedChange = onCheckedChange
    }
    
    public var body: some View {
        Button(action: { onCheckedChange(!checked) }) {
            HStack(spacing: 16) {
                Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(checked ? .accentColor : .secondary)
                    .frame(width: 24, height: 24)
                
                Text(artistName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public struct LoadingSelectableArtistListItem: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            // Checkbox skeleton
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: 24, height: 24)
                .shimmerLoading()
            
            // Name skeleton
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray5))
                .frame(width: 200, height: 18)
                .shimmerLoading()
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 16) {
        SelectableArtistListItem(
            artistName: "Rodrigo y Gabriela",
            checked: true,
            onCheckedChange: { _ in }
        )
        
        Divider()
        
        SelectableArtistListItem(
            artistName: "DragonForce",
            checked: false,
            onCheckedChange: { _ in }
        )
        
        Divider()
        
        LoadingSelectableArtistListItem()
    }
    .padding()
}
