//
//  CarouselViewModel.swift
//  ScrollingLibrary
//
//  Created by Elfo on 13/03/2025.
//

import SwiftUI

/// Carousel view model.
///
/// Subview refers to the child of the content view. Item refers to the elements of the scrollView. There are 3x more items than subviews.
@Observable
@MainActor
class CarouselViewModel {
    
    /// The content view's children count.
    ///
    /// - Important: Do not confuse this value with the scroll view's children count. There are 3x views in the scroll view than subviews' content view.
    @ObservationIgnored var subviewCount = 0
    
    // MARK: - Index and Indices
    
    /// Return the index of a subview from the index of its corresponding item in the scroll view.
    ///
    /// - Parameters:
    ///   - itemIndex: The index of the corresponding item in the scroll view.
    ///   - subviewCount: The number of subviews.
    /// - Returns: The index of a subview.
    static func getSubviewIndex(fromItemIndex itemIndex: Int, subviewCount: Int) -> Int {
        guard subviewCount > 0 else { return 0 }
        return itemIndex % subviewCount
    }
    /// The indices that are valid for subscripting the collection of items, in ascending order.
    ///
    /// - Parameters:
    ///   - subviewCount: The number of subviews.
    /// - Returns: The indices of the collection of items.
    static func getItemIndices(subviewCount: Int) -> Range<Int> {
        0..<(3*subviewCount)
    }
    
    // MARK: - Scrolling
    
    /// The scroll position.
    ///
    /// The index of the current selected item of the scroll view.
    ///
    /// - Important: This is not the index of the current displayed subview. See `CarouselViewModel.getSubviewScrollPosition` for subview index.
    var scrollPosition: Int?
    
    /// Return the scroll position of the current displayed subview.
    ///
    /// Description plus détaillée de la méthode, son contexte d’utilisation,
    /// et tout comportement particulier à noter.
    ///
    /// - Parameters:
    ///   - position: the scroll position of the corresponding item of the scroll view.
    ///
    /// - Returns: The scroll position [0, `CarouselViewModel.subviewCount`[
    func getSubviewScrollPosition(position: Int?) -> Int {
        subviewCount != 0
        ? (position ?? 0) % subviewCount
        : 0
    }
    
    var isScrollingAllowed: Bool = true
    var isScrollDisabled: Bool {
        subviewCount <= 1 || !isScrollingAllowed
    }
    
    func onScrollPhaseChange( _ newPhase: ScrollPhase) {
        switch newPhase {
        case .idle:
            isScrollingAllowed = true
            isAutoScrollingAllowed = true
            updateScrollPositionToPerformInfiniteScrolling()
            startAutoScrolling()
            
        case .decelerating:
            isScrollingAllowed = false
            
        case .interacting:
            isAutoScrollingAllowed = false
            
        default:
            break
        }
    }
    
    private func updateScrollPositionToPerformInfiniteScrolling() {
        if let position = scrollPosition {
            if position < subviewCount {
                scrollPosition = position + subviewCount
            } else if position >= subviewCount * 2 {
                scrollPosition = position - subviewCount
            }
        } else {
            scrollPosition = subviewCount
        }
    }
    
    // MARK: - Auto scrolling
    
    @ObservationIgnored var isAutoScrollingEnabled: Bool = true
    @ObservationIgnored var autoScrollPauseDuration: Double = 3
    @ObservationIgnored var autoScrollDirection: LayoutDirection = .leftToRight
    @ObservationIgnored var isAutoScrollingAllowed: Bool = false
    @ObservationIgnored var isAutoScrollDisabled: Bool {
        !isAutoScrollingAllowed || !isAutoScrollingEnabled
    }
    @ObservationIgnored var autoScrollTask: Task<(), Never>?
    
    func onChangeOfAutoScrolling(
        isEnable: Bool? = nil,
        pauseDuration: Double? = nil,
        direction: LayoutDirection? = nil
    ) {
        if let isEnable {
            isAutoScrollingEnabled = isEnable
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
        if isAutoScrollDisabled {
            autoScrollTask?.cancel()
            print("cancel")
            return
        }
        
        if let autoScrollTask, !autoScrollTask.isCancelled {
            return
        }
        
        print("Start task")
        autoScrollTask = Task(priority: .high, operation: autoScroll)
    }
    
    private func autoScroll() async {
        while true {
            try? await Task.sleep(for: .seconds(autoScrollPauseDuration))
            
            if Task.isCancelled {
                return
            }
            print("auto scroll")
            
            withAnimation {
                if autoScrollDirection == .leftToRight {
                    scrollPosition = (scrollPosition ?? subviewCount - 1) + 1
                } else {
                    scrollPosition = (scrollPosition ?? subviewCount + 1) - 1
                }
            }
        }
    }
    
    // MARK: - Other
    
    func onChangeOfScenePhase(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            startAutoScrolling()
            
        case .inactive, .background:
            autoScrollTask?.cancel()
            print("cancel 2")
            
        @unknown default:
            break
        }
    }
}
