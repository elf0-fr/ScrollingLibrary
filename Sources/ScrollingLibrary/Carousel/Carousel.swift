//
//  Carousel.swift
//  ScrollingLibrary
//
//  Created by Elfo on 05/03/2025.
//

import SwiftUI

public struct Carousel<Content: View>: View {
        
    var content: Content
    
    @State private var viewModel = CarouselViewModel()
    
    @Environment(\.scenePhase) private var scenePhase
        
    @Environment(\.autoScrollingEnabled) private var autoScrollingEnabled
    @Environment(\.autoScrollPauseDuration) private var autoScrollPauseDuration
    @Environment(\.autoScrollDirection) private var autoScrollDirection
    
    @Environment(\.pageIndex) private var pageIndex
    private var scrollPosition: Binding<Int?> {
        Binding {
            viewModel.scrollPosition
        } set: {
            pageIndex.wrappedValue = viewModel.getSubviewScrollPosition(position: $0)
            viewModel.scrollPosition = $0
        }
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        CarouselScrollView(scrollPosition: scrollPosition) {
            content
        }
        .environment(viewModel)
        
        .onAppear {
            scrollPosition.wrappedValue = (pageIndex.wrappedValue ?? 0) + viewModel.subviewCount
        }
        .onChange(of: pageIndex.wrappedValue) {
            let subviewCount = viewModel.subviewCount
            guard subviewCount != 0 else { return }
            guard let newValue = $1 else { return }
            guard let scrollPosition = scrollPosition.wrappedValue else { return }
            guard scrollPosition % subviewCount != newValue % subviewCount else { return }
            
            viewModel.autoScrollTask?.cancel()
            
            withAnimation {
                self.scrollPosition.wrappedValue = newValue + subviewCount
            }
        }
        
        .onChange(of: autoScrollingEnabled, initial: true) { viewModel.onChangeOfAutoScrolling(isEnable: $1)}
        .onChange(of: autoScrollPauseDuration, initial: true) { viewModel.onChangeOfAutoScrolling(pauseDuration: $1) }
        .onChange(of: autoScrollDirection, initial: true) { viewModel.onChangeOfAutoScrolling(direction: $1) }
        
        .onChange(of: scenePhase) { viewModel.onChangeOfScenePhase($1) }
#if DEBUG
        .overlay(alignment: .top) {
            VStack {
                Text("scrollPosition: \(scrollPosition.wrappedValue ?? -1)")
                Text("Internal scrollPosition: \(viewModel.scrollPosition ?? -1)")
                Text("PageIndex: \(pageIndex.wrappedValue ?? -1)")
            }
            .foregroundStyle(.white)
        }
#endif
    }
}

extension Carousel {
    public init<Data: RandomAccessCollection, ID: Hashable, Content2: View>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content2
    ) where Content == ForEach<Data, ID, Content2> {
        self.init {
            ForEach(data, id: id) { content($0) }
        }
    }
}

extension Carousel {
    public init<Data: RandomAccessCollection, ID: Hashable, Content2: View>(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content2
    ) where Content == ForEach<Data, ID, Content2>, Data.Element: Identifiable, ID == Data.Element.ID {
        self.init {
            ForEach(data, id: \.id) { content($0) }
        }
    }
}

// This preview is there so that swiftUI context menu action are visible.
// To play with carousel previews see: CarouselPreviews file.
#Preview {
    Text("Hello, World!")
}
