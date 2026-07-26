//
//  ShimmerViewModifier.swift
//  seen-them-live-ios
//
//  Created by Anthony Swago on 7/26/26.
//

import SwiftUI

public struct ShimmerViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0.0
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width = geometry.size.width
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemGray5),
                            Color(.systemGray4),
                            Color(.systemGray5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .scaleEffect(1.5)
                    .offset(x: (phase - 0.5) * width * 2)
                    .mask(content)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 1.0
                        }
                    }
                }
            )
    }
}

public extension View {
    func shimmerLoading() -> some View {
        modifier(ShimmerViewModifier())
    }
}
