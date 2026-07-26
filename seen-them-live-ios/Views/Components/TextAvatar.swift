//
//  TextAvatar.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct TextAvatar: View {
    let character: Character
    
    public init(character: Character) {
        self.character = character
    }
    
    public var body: some View {
        Text(String(character).uppercased())
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
            .frame(width: 40, height: 40)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Circle())
    }
}

#Preview {
    TextAvatar(character: "A")
        .padding()
}
