//
//  CarouselViewModel.swift
//  ScrollingLibrary
//
//  Created by Elfo on 13/03/2025.
//

import SwiftUI

@Observable
@MainActor
class CarouselViewModel {
    
    var subviewsCount = 0
    
    var isAutoScrollingEnabled: Bool = true
    var isAutoScrollingAllowed: Bool = false
    var autoScrollPauseDuration: Double = 3
    var autoScrollDirection: LayoutDirection = .leftToRight
    var autoScrollTask: Task<(), Never>?
    
    var isDragActive: Bool = true
    var scrollPosition: Int?
    func setScrollPosition(_ position: Int?, pageIndex: Binding<Int?>) {
        if subviewsCount != 0  {
            pageIndex.wrappedValue = (position ?? 0) % subviewsCount
        }
        scrollPosition = position
    }
    
    func getId(loopIndex: Int, index: Int) -> Int {
        index + loopIndex * subviewsCount
    }
    
    func onScrollPhaseChange( _ newPhase: ScrollPhase) {
        switch newPhase {
        case .idle:
            isDragActive = true
            isAutoScrollingAllowed = true
            updateScrollPositionToPerformInfiniteScrolling()
            
        case .decelerating:
            isDragActive = false
            
        case .interacting:
            isAutoScrollingAllowed = false
            
        default:
            break
        }
    }
    
    private func updateScrollPositionToPerformInfiniteScrolling() {
        if let position = scrollPosition {
            if position < subviewsCount {
                scrollPosition = position + subviewsCount
            } else if position >= subviewsCount * 2 {
                scrollPosition = position - subviewsCount
            }
        } else {
            scrollPosition = subviewsCount
        }
    }
    
    func onChangeOfAutoScrolling(
        isEnable: Bool? = nil,
        isAllowed: Bool? = nil,
        pauseDuration: Double? = nil,
        direction: LayoutDirection? = nil
    ) {
        if let isEnable {
            isAutoScrollingEnabled = isEnable
        }
        if let isAllowed {
            isAutoScrollingAllowed = isAllowed
        }
        if let pauseDuration {
            autoScrollPauseDuration = pauseDuration
        }
        if let direction {
            autoScrollDirection = direction
        }
        
        startAutoScrolling()
    }
    
    private func startAutoScrolling() {
        if isAutoScrollingAllowed && isAutoScrollingEnabled {
            if let autoScrollTask, !autoScrollTask.isCancelled {
                return
            }
            
            autoScrollTask = Task(priority: .high, operation: autoScroll)
        } else {
            autoScrollTask?.cancel()
        }
    }
    
    private func autoScroll() async {
        while true {
            try? await Task.sleep(for: .seconds(autoScrollPauseDuration))
            
            if Task.isCancelled {
                return
            }
            
            withAnimation {
                if autoScrollDirection == .leftToRight {
                    scrollPosition = (scrollPosition ?? subviewsCount - 1) + 1
                } else {
                    scrollPosition = (scrollPosition ?? subviewsCount + 1) - 1
                }
            }
        }
    }
    
    func onChangeOfScenePhase(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            startAutoScrolling()
            
        case .inactive, .background:
            autoScrollTask?.cancel()
            
        @unknown default:
            break
        }
    }
}
