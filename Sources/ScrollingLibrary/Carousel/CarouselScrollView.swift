//
//  CarouselScrollView.swift
//  ScrollingLibrary
//
//  Created by Elfo on 13/03/2025.
//

import SwiftUI

struct CarouselScrollView<Content: View>: View {
    
    @ViewBuilder var content: Content
    
    @Environment(CarouselViewModel.self) private var viewModel
    @Environment(\.carouselStyle) private var style
    
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
                                        .id(index)
                                })
                        )
                    }
                }
                .scrollTargetLayout()
            }
            .scrollDisabled(viewModel.isScrollDisabled)
            .scrollIndicators(.never, axes: .horizontal)
            .scrollBounceBehavior(.always)
            .scrollTargetBehavior(.paging)
            .onScrollPhaseChange { viewModel.onScrollPhaseChange($1) }
            
            .onChange(of: subviewCount, initial: true) {
                viewModel.subviewCount = $1
            }
        }
        .onDisappear {
            viewModel.autoScrollTask?.cancel()
        }
    }
}
