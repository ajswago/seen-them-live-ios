//
//  SearchCard.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct SearchCard: View {
    @State private var artist: String = ""
    @State private var venue: String = ""
    @State private var usState: UsState = .none
    
    let onSearch: (SearchTerms) -> Void
    let enabled: Bool
    
    public init(enabled: Bool = true, onSearch: @escaping (SearchTerms) -> Void) {
        self.enabled = enabled
        self.onSearch = onSearch
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Search Shows")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 16) {
                // Artist field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Artist Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("e.g. Lamb of God", text: $artist)
                            .disabled(!enabled)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled(true)
                        
                        if !artist.isEmpty && enabled {
                            Button(action: { artist = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                // Venue field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Venue Name")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("e.g. The Fillmore", text: $venue)
                            .disabled(!enabled)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled(true)
                        
                        if !venue.isEmpty && enabled {
                            Button(action: { venue = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                
                // State selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("US State")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Picker("US State", selection: $usState) {
                        ForEach(UsState.allCases) { state in
                            Text(state.stateName)
                                .tag(state)
                        }
                    }
                    .disabled(!enabled)
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            
            Button(action: {
                let searchTerms = SearchTerms(
                    artist: artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : artist,
                    venue: venue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : venue,
                    usState: usState == .none ? nil : usState.rawValue
                )
                onSearch(searchTerms)
            }) {
                Text("Search")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(enabled ? Color.accentColor : Color.secondary.opacity(0.4))
                    .cornerRadius(12)
                    .shadow(color: enabled ? Color.accentColor.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .disabled(!enabled)
            .padding(.top, 8)
        }
        .padding(24)
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

#Preview {
    SearchCard(onSearch: { _ in })
        .padding()
        .background(Color(.systemGroupedBackground))
}
