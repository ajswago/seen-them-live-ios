//
//  GroupedShowListItem.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct GroupedShowListItem: View {
    let venueName: String
    let city: String
    let state: String
    let artistList: [String]
    let date: Date
    let onClick: (() -> Void)?
    
    public init(
        venueName: String,
        city: String,
        state: String,
        artistList: [String],
        date: Date,
        onClick: (() -> Void)? = nil
    ) {
        self.venueName = venueName
        self.city = city
        self.state = state
        self.artistList = artistList
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
                    
                    Text(venueName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(artistList.formatCommaSeparatedString(maxDisplayed: 2))
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
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public struct LoadingGroupedShowListItem: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                // Location skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
                    .shimmerLoading()
                
                // Venue name skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 180, height: 18)
                    .shimmerLoading()
                
                // Artists skeleton
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
        .padding(.vertical, 12)
    }
}

// MARK: - String Array Formatting Extension

public extension Array where Element == String {
    func formatCommaSeparatedString(maxDisplayed: Int) -> String {
        let sortedList = self.sorted()
        let displayed = sortedList.prefix(maxDisplayed)
        var result = displayed.joined(separator: ", ")
        if self.count > maxDisplayed {
            result += " +\(self.count - maxDisplayed)"
        }
        return result
    }
}

#Preview {
    VStack(spacing: 16) {
        GroupedShowListItem(
            venueName: "Jiffy Lube Live",
            city: "Bristow",
            state: "VA",
            artistList: ["Anthrax", "Behemoth", "Slayer", "Lamb of God"],
            date: Date(),
            onClick: {}
        )
        
        Divider()
        
        LoadingGroupedShowListItem()
    }
    .padding()
}
