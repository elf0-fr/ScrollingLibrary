//
//  Carousel.swift
//  ScrollingLibrary
//
//  Created by Elfo on 05/03/2025.
//

import SwiftUI

public struct Carousel<Content: View>: View {
        
//    @Binding var scrollPosition: Int?
    var content: Content
    
    @State private var viewModel = CarouselViewModel()

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
                        viewModel.internalScrollPosition = viewModel.subviewsCount
                    }
            }
        }
        .scrollPosition(id: $viewModel.internalScrollPosition)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .onScrollPhaseChange { viewModel.onScrollPhaseChange($1) }
        .scrollTargetBehavior(.paging)
        .scrollDisabled(!viewModel.isDragActive)
#if DEBUG
        .overlay(alignment: .top) {
            Text("scrollPosition: \(viewModel.internalScrollPosition ?? -1)")
                .foregroundStyle(.white)
        }
#endif
    }
}


@Observable
@MainActor
class CarouselViewModel {
    
    var subviewsCount = 0
    var internalScrollPosition: Int?
    var isDragActive: Bool = true
    
    var scrollPosition: Int {
        get {
            (internalScrollPosition ?? 0) % subviewsCount
        }
        set {
            internalScrollPosition = newValue + subviewsCount
        }
    }
    
    static func getId(loopIndex: Int, index: Int) -> Int {
        index + loopIndex * 4
    }
    
    func onScrollPhaseChange( _ newPhase: ScrollPhase) {
        switch newPhase {
        case .idle:
            isDragActive = true
            updateScrollPositionToPerformInfiniteScrollingTowardLeft()
            updateScrollPositionToPerformInfiniteScrollingTowardRight()
            
        case .decelerating:
            isDragActive = false
            
        default:
            break
        }
    }
    
    private func updateScrollPositionToPerformInfiniteScrollingTowardLeft() {
        guard let internalScrollPosition else { return }
        
        if internalScrollPosition < subviewsCount {
            self.internalScrollPosition = internalScrollPosition + self.subviewsCount
        }
    }
    
    private func updateScrollPositionToPerformInfiniteScrollingTowardRight() {
        guard let internalScrollPosition else { return }
        
        if internalScrollPosition >= subviewsCount * 2 {
            self.internalScrollPosition = internalScrollPosition - self.subviewsCount
        }
    }
}

#Preview {
//        @Previewable @State var scrollPosition: Int?
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
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
    .frame(width: 300)
    .background {
        RoundedRectangle(cornerRadius: 25)
    }
}
