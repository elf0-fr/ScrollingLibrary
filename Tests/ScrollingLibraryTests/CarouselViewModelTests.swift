//
//  CarouselViewModelTests.swift
//  ScrollingLibrary
//
//  Created by Elfo on 08/03/2025.
//


import Testing
import SwiftUI
@testable import ScrollingLibrary

struct ScrollPosition: CustomTestStringConvertible {
    let initialPosition: Int?
    let positionAfterComputations: Int
    
    var testDescription: String {
        "Initial position: \(initialPosition?.description ?? "nil"), final position: \(positionAfterComputations)"
    }
}

struct AutoScrolling: CustomTestStringConvertible {
    let isEnabled: Bool?
    let isAllowed: Bool?
    let pauseDuration: Double?
    let direction: LayoutDirection?
    
    var testDescription: String {
        "Auto scrolling \((isEnabled ?? false) ? "enabled" : "disabled"), \((isAllowed ?? false) ? "allowed" : "not allowed"), pause duration: \(pauseDuration?.description ?? "nil"), direction: \(direction?.description ?? "nil")"
    }
}

@MainActor struct CarouselViewModelTests {
    let viewModel = CarouselViewModel()
        
    @Test("Index of a subview") func getSubviewIndex() {
        #expect(
            CarouselViewModel.getSubviewIndex(fromItemIndex: Int.random(in: 0..<10), subviewCount: 0) == 0,
            "Edge case where subviewCount is 0"
        )
        #expect(
            CarouselViewModel.getSubviewIndex(fromItemIndex: Int.random(in: 0..<10), subviewCount: 1) == 0,
            "Edge case where subviewCount is 1"
        )
        #expect(CarouselViewModel.getSubviewIndex(fromItemIndex: 5, subviewCount: 2) == 1)
        #expect(CarouselViewModel.getSubviewIndex(fromItemIndex: 3, subviewCount: 3) == 0)
        #expect(CarouselViewModel.getSubviewIndex(fromItemIndex: 1, subviewCount: 4) == 1)
    }
    
    @Test("Indices of items") func getItemIndices() {
        #expect(CarouselViewModel.getItemIndices(subviewCount: 1) == 0..<3)
        #expect(CarouselViewModel.getItemIndices(subviewCount: 2) == 0..<6)
        #expect(CarouselViewModel.getItemIndices(subviewCount: 5) == 0..<15)
        #expect(CarouselViewModel.getItemIndices(subviewCount: 0) == 0..<0)
    }
    
    @Test("Subview scroll position") func getSubviewScrollPosition() {
        viewModel.subviewCount = 5
        #expect(viewModel.getSubviewScrollPosition(position: 7) == 2)
        #expect(viewModel.getSubviewScrollPosition(position: nil) == 0)
        
        viewModel.subviewCount = 0
        #expect(viewModel.getSubviewScrollPosition(position: 3) == 0)
        #expect(viewModel.getSubviewScrollPosition(position: nil) == 0)
    }
    
    @MainActor struct OnScrollPhaseChange {
        let viewModel = CarouselViewModel()
        
        @Test(
            "Scroll phase change to idle",
            arguments: [
                ScrollPosition(initialPosition: 4, positionAfterComputations: 9),
                ScrollPosition(initialPosition: 5, positionAfterComputations: 5),
                ScrollPosition(initialPosition: 6, positionAfterComputations: 6),
                ScrollPosition(initialPosition: 7, positionAfterComputations: 7),
                ScrollPosition(initialPosition: 8, positionAfterComputations: 8),
                ScrollPosition(initialPosition: 9, positionAfterComputations: 9),
                ScrollPosition(initialPosition: 10, positionAfterComputations: 5),
                ScrollPosition(initialPosition: nil, positionAfterComputations: 5),
            ],
            [ true, false ]
        )
        func onScrollPhaseChange_idle(
            scrollPosition: ScrollPosition,
            isAutoScrollingEnabled: Bool
        ) {
            viewModel.subviewCount = 5
            viewModel.isScrollingAllowed = Bool.random()
            viewModel.isAutoScrollingEnabled = isAutoScrollingEnabled
            viewModel.scrollPosition = scrollPosition.initialPosition
            
            viewModel.onScrollPhaseChange(.idle)
            
            #expect(viewModel.isScrollingAllowed)
            #expect(viewModel.isAutoScrollingEnabled == isAutoScrollingEnabled)
            #expect(viewModel.scrollPosition ==  scrollPosition.positionAfterComputations)
        }
        
        @Test("Scroll phase change to decelerating", arguments: [
            true, false
        ])
        func onScrollPhaseChange_decelerating(isScrollingAllowed: Bool) {
            viewModel.isScrollingAllowed = isScrollingAllowed
            
            viewModel.onScrollPhaseChange(.decelerating)
            
            #expect(!viewModel.isScrollingAllowed)
        }
        
        @Test("Scroll phase change to interacting", arguments: [
            true, false
        ])
        func onScrollPhaseChange_interacting(allowed: Bool) {
            viewModel.onScrollPhaseChange(.interacting)
            
            #expect(viewModel.autoScrollTask?.isCancelled ?? true)
        }
    }
    
    @Test("Auto scrolling", arguments: [
        AutoScrolling(isEnabled: true, isAllowed: true, pauseDuration: 0.1, direction: .leftToRight),
        AutoScrolling(isEnabled: false, isAllowed: false, pauseDuration: 0.3, direction: .rightToLeft),
    ])
    func onChangeOfAutoScrolling(autoScrolling: AutoScrolling) {
        viewModel.isAutoScrollingEnabled = Bool.random()
        viewModel.autoScrollPauseDuration = Double.random(in: 0...1)
        viewModel.autoScrollDirection = .allCases.randomElement()!
        
        viewModel.onChangeOfAutoScrolling(
            isEnable: autoScrolling.isEnabled,
            pauseDuration: autoScrolling.pauseDuration,
            direction: autoScrolling.direction
        )
        
        #expect(viewModel.isAutoScrollingEnabled == autoScrolling.isEnabled)
        #expect(viewModel.autoScrollPauseDuration == autoScrolling.pauseDuration)
        #expect(viewModel.autoScrollDirection == autoScrolling.direction)
    }
    
    @Test("Scene phase change") func onChangeOfScenePhase() throws {
        viewModel.isAutoScrollingEnabled = true
        viewModel.autoScrollPauseDuration = 1
        
        viewModel.onChangeOfScenePhase(.active)
        
        let task = try! #require(viewModel.autoScrollTask)
        #expect(!task.isCancelled)
        
        viewModel.onChangeOfScenePhase(.inactive)
        
        #expect(task.isCancelled)
    }
}
