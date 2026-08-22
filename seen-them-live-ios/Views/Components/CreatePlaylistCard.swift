//
//  CreatePlaylistCard.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 8/21/26.
//

import SwiftUI

public struct CreatePlaylistCard: View {
    @Binding var playlistName: String
    let enabled: Bool
    let onCreate: () -> Void
    
    public init(playlistName: Binding<String>, enabled: Bool = true, onCreate: @escaping () -> Void) {
        self._playlistName = playlistName
        self.enabled = enabled
        self.onCreate = onCreate
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Create Spotify Playlist")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Playlist Name")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("e.g. My Concerts Playlist", text: $playlistName)
                        .disabled(!enabled)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled(true)
                    
                    if !playlistName.isEmpty && enabled {
                        Button(action: { playlistName = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            Button(action: onCreate) {
                Text("Create")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(enabled && !playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.accentColor : Color.secondary.opacity(0.4))
                    .cornerRadius(12)
                    .shadow(color: enabled && !playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.accentColor.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
            }
            .disabled(!enabled || playlistName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
    CreatePlaylistCard(playlistName: .constant("My Concerts Playlist"), enabled: true, onCreate: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}
