//
//  ExpandableShowHeader.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ExpandableShowHeader: View {
    let venueName: String
    let city: String
    let state: String
    let date: Date
    let expanded: Bool
    let onExpandedChange: (BooleanLiteralType) -> Void
    
    public init(
        venueName: String,
        city: String,
        state: String,
        date: Date,
        expanded: Bool,
        onExpandedChange: @escaping (BooleanLiteralType) -> Void
    ) {
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.expanded = expanded
        self.onExpandedChange = onExpandedChange
    }
    
    public var body: some View {
        Button(action: { onExpandedChange(!expanded) }) {
            HStack(spacing: 16) {
                Image(systemName: expanded ? "chevron.down" : "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(venueName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(city), \(state)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(date.formatForDisplay())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public struct LoadingExpandableShowHeader: View {
    public init() {}
    
    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundColor(Color(.systemGray5))
                .frame(width: 20)
                .shimmerLoading()
            
            VStack(alignment: .leading, spacing: 6) {
                // Venue name skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 180, height: 18)
                    .shimmerLoading()
                
                // Location skeleton
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
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
        ExpandableShowHeader(
            venueName: "Capital One Hall",
            city: "Tysons Corner",
            state: "VA",
            date: Date(),
            expanded: true,
            onExpandedChange: { _ in }
        )
        
        Divider()
        
        LoadingExpandableShowHeader()
    }
    .padding()
}
