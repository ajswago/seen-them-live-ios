//
//  SelectableShowListGroup.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct SelectableShowListGroup: View {
    let venueName: String
    let city: String
    let state: String
    let date: Date
    let artistList: [String]
    let selections: [String: Bool]
    let onArtistSelected: (Int, Bool) -> Void
    
    @State private var expanded: Bool = true
    
    public init(
        venueName: String,
        city: String,
        state: String,
        date: Date,
        artistList: [String],
        selections: [String: Bool],
        onArtistSelected: @escaping (Int, Bool) -> Void
    ) {
        self.venueName = venueName
        self.city = city
        self.state = state
        self.date = date
        self.artistList = artistList
        self.selections = selections
        self.onArtistSelected = onArtistSelected
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
                ForEach(Array(artistList.enumerated()), id: \.offset) { index, artist in
                    SelectableArtistListItem(
                        artistName: artist,
                        checked: selections[artist] ?? false,
                        onCheckedChange: { onArtistSelected(index, $0) }
                    )
                    
                    Divider()
                }
            }
        }
    }
}

public struct LoadingSelectableShowListGroup: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LoadingExpandableShowHeader()
            
            Divider()
            
            LoadingSelectableArtistListItem()
            
            Divider()
            
            LoadingSelectableArtistListItem()
            
            Divider()
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        StatefulPreviewWrapper()
        
        Divider()
        
        LoadingSelectableShowListGroup()
    }
    .padding()
}

// A simple wrapper to handle preview state updates
private struct StatefulPreviewWrapper: View {
    let artists = ["Dethklok", "DragonForce", "Nekrogoblikon"]
    @State private var selections: [String: Bool] = [
        "Dethklok": true,
        "DragonForce": false,
        "Nekrogoblikon": false
    ]
    
    var body: some View {
        SelectableShowListGroup(
            venueName: "The Fillmore Silver Spring",
            city: "Silver Spring",
            state: "MD",
            date: Date(),
            artistList: artists,
            selections: selections,
            onArtistSelected: { index, selected in
                selections[artists[index]] = selected
            }
        )
    }
}
