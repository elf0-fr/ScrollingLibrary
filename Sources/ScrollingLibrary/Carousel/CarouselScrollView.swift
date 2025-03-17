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
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(0...2, id: \.self) { loopIndex in
                    Group(subviews: content) { subviews in
                        ForEach(subviews.indices, id: \.self) { index in
                            subviews[index]
                                .containerRelativeFrame(.horizontal)
                                .id(viewModel.getId(loopIndex: loopIndex, index: index))
                        }
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.never, axes: .horizontal)
    }
}
