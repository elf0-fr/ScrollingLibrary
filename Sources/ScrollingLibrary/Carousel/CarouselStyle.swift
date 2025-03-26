//
//  CarouselStyle.swift
//  ScrollingLibrary
//
//  Created by Elfo on 17/03/2025.
//

import SwiftUI

public protocol CarouselStyle {
    associatedtype Body: View
    typealias Configuration = CarouselConfiguration
    
    func makeBody(configuration: Configuration) -> Body
}

public struct CarouselConfiguration {
    public struct Label: View {
        init<Content: View>(@ViewBuilder content: () -> Content) {
            self.body = AnyView(content())
        }
        
        public var body: AnyView
    }
    
    public let viewCount: Int
    public let index: Int
    public let label: Label
}

extension EnvironmentValues {
    @Entry var carouselStyle = AnyCarouselStyle(DefaultCarouselStyle())
}

extension View {
    public func carouselStyle<S: CarouselStyle>(_ style: S) -> some View {
        environment(\.carouselStyle, AnyCarouselStyle(style))
    }
}

struct AnyCarouselStyle: CarouselStyle {
    private let _makeBody: (Configuration) -> AnyView
    
    init<S: CarouselStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

public struct DefaultCarouselStyle: CarouselStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.containerRelativeFrame(.horizontal)
    }
}
