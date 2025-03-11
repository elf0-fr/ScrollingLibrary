//
//  DotsIndicator.swift
//  ScrollingLibrary
//
//  Created by Elfo on 09/03/2025.
//

import SwiftUI

// MARK: - auto Scrolling Enabled

extension EnvironmentValues {
    @Entry var autoScrollingEnabled: Bool = false
}

extension View {
    public func autoScrollingEnabled(_ enabled: Bool) -> some View {
        environment(\.autoScrollingEnabled, enabled)
    }
}

// MARK: - auto Scroll PauseDuration

extension EnvironmentValues {
    @Entry var autoScrollPauseDuration: Double = 3
}

extension View {
    public func autoScrollPauseDuration(_ duration: Double) -> some View {
        environment(\.autoScrollPauseDuration, duration)
    }
}
