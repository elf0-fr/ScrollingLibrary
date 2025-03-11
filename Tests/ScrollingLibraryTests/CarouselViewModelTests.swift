//
//  CarouselViewModelTests.swift
//  ScrollingLibrary
//
//  Created by Elfo on 08/03/2025.
//


import Testing
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
    
    var testDescription: String {
        "Auto scrolling \((isEnabled ?? false) ? "enabled" : "disabled"), \((isAllowed ?? false) ? "allowed" : "not allowed"), pause duration: \(pauseDuration?.description ?? "nil")"
    }
}

@MainActor struct CarouselViewModelTests {
    let viewModel = CarouselViewModel()
        
    @Test("Id of a subview") func getId() {
        #expect(CarouselViewModel.getId(loopIndex: 0, index: 1) == 1)
        #expect(CarouselViewModel.getId(loopIndex: 1, index: 2) == 6)
        #expect(CarouselViewModel.getId(loopIndex: 2, index: 3) == 11)
    }
    
    @Test("Get scroll position [0, subviewsCount[", arguments: [
        ScrollPosition(initialPosition: 4, positionAfterComputations: 4),
        ScrollPosition(initialPosition: 5, positionAfterComputations: 0),
        ScrollPosition(initialPosition: 6, positionAfterComputations: 1),
        ScrollPosition(initialPosition: 7, positionAfterComputations: 2),
        ScrollPosition(initialPosition: 8, positionAfterComputations: 3),
        ScrollPosition(initialPosition: 9, positionAfterComputations: 4),
        ScrollPosition(initialPosition: 10, positionAfterComputations: 0),
        ScrollPosition(initialPosition: nil, positionAfterComputations: 0),
    ])
    func getScrollPosition(scrollPosition: ScrollPosition) {
        viewModel.subviewsCount = 5
        
        viewModel.internalScrollPosition = scrollPosition.initialPosition
        
        #expect(viewModel.scrollPosition == scrollPosition.positionAfterComputations)
    }
    
    @Test("Set scroll position [0, subviewsCount[", arguments: [
        ScrollPosition(initialPosition: 0, positionAfterComputations: 5),
        ScrollPosition(initialPosition: 1, positionAfterComputations: 6),
        ScrollPosition(initialPosition: 2, positionAfterComputations: 7),
        ScrollPosition(initialPosition: 3, positionAfterComputations: 8),
        ScrollPosition(initialPosition: 4, positionAfterComputations: 9),
    ])
    func setScrollPosition(scrollPosition: ScrollPosition) {
        viewModel.subviewsCount = 5
        viewModel.internalScrollPosition = Int.random(in: 5...9)
        
        viewModel.scrollPosition = scrollPosition.initialPosition!
        
        #expect(viewModel.internalScrollPosition == scrollPosition.positionAfterComputations)
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
            viewModel.subviewsCount = 5
            viewModel.isDragActive = Bool.random()
            viewModel.isAutoScrollingEnabled = isAutoScrollingEnabled
            viewModel.isAutoScrollingAllowed = Bool.random()
            viewModel.internalScrollPosition = scrollPosition.initialPosition
            
            viewModel.onScrollPhaseChange(.idle)
            
            #expect(viewModel.isDragActive)
            #expect(viewModel.isAutoScrollingEnabled == isAutoScrollingEnabled)
            #expect(viewModel.isAutoScrollingAllowed)
            #expect(viewModel.internalScrollPosition ==  scrollPosition.positionAfterComputations)
        }
        
        @Test("Scroll phase change to decelerating", arguments: [
            true, false
        ])
        func onScrollPhaseChange_decelerating(isDragActive: Bool) {
            viewModel.isDragActive = isDragActive
            
            viewModel.onScrollPhaseChange(.decelerating)
            
            #expect(!viewModel.isDragActive)
        }
        
        @Test("Scroll phase change to interacting", arguments: [
            true, false
        ])
        func onScrollPhaseChange_interacting(allowed: Bool) {
            viewModel.isAutoScrollingAllowed = allowed
            
            viewModel.onScrollPhaseChange(.interacting)
            
            #expect(!viewModel.isAutoScrollingAllowed)
        }
    }
    
    @Test("Auto scrolling", arguments: [
        AutoScrolling(isEnabled: true, isAllowed: true, pauseDuration: 0.1),
        AutoScrolling(isEnabled: false, isAllowed: false, pauseDuration: 0.3),
    ])
    func onChangeOfAutoScrolling(autoScrolling: AutoScrolling) {
        viewModel.isAutoScrollingEnabled = Bool.random()
        viewModel.isAutoScrollingAllowed = Bool.random()
        viewModel.autoScrollPauseDuration = Double.random(in: 0...1)
        
        viewModel.onChangeOfAutoScrolling(
            isEnable: autoScrolling.isEnabled,
            isAllowed: autoScrolling.isAllowed,
            pauseDuration: autoScrolling.pauseDuration
        )
        
        #expect(viewModel.isAutoScrollingEnabled == autoScrolling.isEnabled)
        #expect(viewModel.isAutoScrollingEnabled == autoScrolling.isAllowed)
        #expect(viewModel.autoScrollPauseDuration == autoScrolling.pauseDuration)
    }
    
    @Test("Scene phase change") func onChangeOfScenePhase() throws {
        viewModel.isAutoScrollingEnabled = true
        viewModel.isAutoScrollingAllowed = true
        viewModel.autoScrollPauseDuration = 1
        
        viewModel.onChangeOfScenePhase(.active)
        
        let task = try! #require(viewModel.autoScrollTask)
        #expect(!task.isCancelled)
        
        viewModel.onChangeOfScenePhase(.inactive)
        
        #expect(task.isCancelled)
    }
}
