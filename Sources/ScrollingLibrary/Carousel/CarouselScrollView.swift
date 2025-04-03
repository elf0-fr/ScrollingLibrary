//
//  CarouselScrollView.swift
//  ScrollingLibrary
//
//  Created by Elfo on 13/03/2025.
//

import SwiftUI

struct CarouselScrollView<Content: View>: View {
    
    @Environment(CarouselViewModel.self) private var viewModel
    @Environment(\.carouselStyle) private var style
    
    @Binding var scrollPosition: Int?
    
    @ViewBuilder var content: Content
    
    var body: some View {
        Group(subviews: content) { subviews in
            // Subview refers to the child of the content view.
            // Item refers to the item of the scrollView.
            // There are 3x more items than subviews.
            
            let subviewCount = subviews.count
            let itemIndexes = CarouselViewModel.getItemIndices(subviewCount: subviewCount)
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(itemIndexes, id: \.self) { index in
                        let subviewIndex = CarouselViewModel.getSubviewIndex(
                            fromItemIndex: index,
                            subviewCount: subviewCount
                        )
                        style.makeBody(
                            configuration: CarouselConfiguration(
                                viewCount: subviewCount,
                                index: subviewIndex,
                                label: CarouselConfiguration.Label {
                                    subviews[subviewIndex]
                                        .accessibilityIdentifier("carouselElement_\(index)")
                                        .id(index)
                                })
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollPosition)
            .scrollDisabled(subviewCount <= 1 || !viewModel.isScrollingAllowed)
            .scrollIndicators(.never, axes: .horizontal)
            .scrollBounceBehavior(.always)
            .scrollTargetBehavior(.paging)
            .onScrollPhaseChange { viewModel.onScrollPhaseChange($1) }
            
            .onChange(of: subviewCount, initial: true) {
                viewModel.subviewCount = $1
                let subviewIndex = CarouselViewModel.getSubviewIndex(fromItemIndex: scrollPosition ?? 0, subviewCount: $0)
                scrollPosition = CarouselViewModel.getItemIndex(fromSubviewIndex: subviewIndex, subviewCount: $1)
            }
        }
        .onDisappear {
            viewModel.autoScrollTask?.cancel()
        }
    }
}
