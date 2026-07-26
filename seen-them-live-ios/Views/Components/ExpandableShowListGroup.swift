//
//  ExpandableShowListGroup.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ExpandableShowListGroup: View {
    let venueName: String
    let city: String
    let state: String
    let date: Date
    let artistList: [String]
    let onArtistClick: ((Int) -> Void)?
    
    @State private var expanded: Bool = true
    
    public init(
        venueName: String,
        city: String,
        state: String,
        date: Date,
        artistList: [String],
        onArtistClick: ((Int) -> Void)? = nil
    ) {
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.artistList = artistList
        self.onArtistClick = onArtistClick
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ExpandableShowHeader(
                venueName: venueName,
                city: city,
                state: state,
                date: date,
                expanded: expanded,
                onExpandedChange: { expanded = $0 }
            )
            
            Divider()
            
            if expanded {
                ForEach(Array(artistList.enumerated()), id: \.offset) { index, name in
                    ArtistListItem(
                        artistName: name,
                        indent: true,
                        onClick: { onArtistClick?(index) }
                    )
                    
                    Divider()
                }
            }
        }
    }
}

public struct LoadingExpandableShowListGroup: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LoadingExpandableShowHeader()
            
            Divider()
            
            LoadingArtistListItemSimple()
            
            Divider()
            
            LoadingArtistListItemSimple()
            
            Divider()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ExpandableShowListGroup(
            venueName: "The Fillmore Silver Spring",
            city: "Silver Spring",
            state: "MD",
            date: Date(),
            artistList: ["DragonForce", "Nekrogoblikon"],
            onArtistClick: { print("Tapped artist index \($0)") }
        )
        
        Divider()
        
        LoadingExpandableShowListGroup()
    }
    .padding()
}
