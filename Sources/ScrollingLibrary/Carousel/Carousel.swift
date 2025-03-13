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
        } set: { newValue in
            viewModel.setScrollPosition(newValue, pageIndex: pageIndex)
        }
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0...2, id: \.self) { loopIndex in
                    Group(subviews: content) { subviews in
                        ForEach(subviews.indices, id: \.self) { index in
                            subviews[index]
                                .id(CarouselViewModel.getId(loopIndex: loopIndex, index: index))
                        }
                    }
                }
            }
            .scrollTargetLayout()
        }
        .background {
            Group(subviews: content) { subviews in
                Color.clear
                    .onAppear {
                        // Get the subviews count.
                        viewModel.subviewsCount = subviews.count
                        
                        // start at the first item of the second loop.
                        scrollPosition.wrappedValue = (pageIndex.wrappedValue ?? 0) + viewModel.subviewsCount
                        
                        // auto scrolling settings
                        viewModel.isAutoScrollingEnabled = autoScrollingEnabled
                        viewModel.autoScrollPauseDuration = autoScrollPauseDuration
                    }
                    .onDisappear {
                        viewModel.autoScrollTask?.cancel()
                    }
            }
        }
        .scrollPosition(id: scrollPosition)
        .scrollDisabled(!viewModel.isDragActive)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .scrollTargetBehavior(.paging)
        .onScrollPhaseChange { viewModel.onScrollPhaseChange($1) }
        .onChange(of: pageIndex.wrappedValue, { _, newValue in
            guard viewModel.subviewsCount != 0 else { return }
            
            if let scrollPosition = scrollPosition.wrappedValue,
               let value = newValue,
               scrollPosition % viewModel.subviewsCount != value % viewModel.subviewsCount {
                withAnimation {
                    self.scrollPosition.wrappedValue = (newValue ?? 0) + viewModel.subviewsCount
                }
            }
        })
        .onChange(of: autoScrollingEnabled) { viewModel.onChangeOfAutoScrolling(isEnable: $1)}
        .onChange(of: autoScrollPauseDuration) { viewModel.onChangeOfAutoScrolling(pauseDuration: $1) }
        .onChange(of: autoScrollDirection) { viewModel.onChangeOfAutoScrolling(direction: $1) }
        .onChange(of: viewModel.isAutoScrollingAllowed) { viewModel.onChangeOfAutoScrolling(isAllowed: $1) }
        .onChange(of: scenePhase) { viewModel.onChangeOfScenePhase($1) }
#if DEBUG
        .overlay(alignment: .top) {
            Text("scrollPosition: \(scrollPosition.wrappedValue ?? -1), \ninternal: \(viewModel.scrollPosition ?? -1)")
                .foregroundStyle(.white)
        }
#endif
    }
}

#Preview {
    @Previewable @State var pageIndex: Int?
    @Previewable @State var autoScrollingEnabled: Bool = false
    @Previewable @State var rightToLeft: Bool = false
    @Previewable @State var autoScrollPauseDuration: Double = 3
    
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    VStack {
        GroupBox {
            Toggle("Enable auto scrolling", isOn: $autoScrollingEnabled)
            Toggle("\(rightToLeft ? "Right to Left" : "Left to Right")", isOn: $rightToLeft)
            Stepper("Pause Duration: \(autoScrollPauseDuration.formatted())", value: $autoScrollPauseDuration, in: 1...5)
        }
        
        Carousel {
            let with: CGFloat = 250
            let height: CGFloat = 350
            let widthDiff: CGFloat = 300 - with
            
            ForEach(colors.indices, id: \.self) { index in
                let color = colors[index]
                
                Text("\(color)\nindex: \(index)")
                    .foregroundStyle(.white)
                    .frame(width: with, height: height)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(color)
                    }
                    .padding(.horizontal, widthDiff / 2)
            }
        }
        .pageIndex($pageIndex)
        .autoScrollingEnabled(autoScrollingEnabled)
        .autoScrollPauseDuration(autoScrollPauseDuration)
        .autoScrollDirection(rightToLeft ? .rightToLeft : .leftToRight)
        .frame(width: 300)
        .background {
            RoundedRectangle(cornerRadius: 25)
        }
        .overlay(alignment: .bottom) {
            DotsIndicator(scrollPosition: $pageIndex, itemsCount: colors.count)
        }
    }
}
