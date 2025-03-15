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
        
    @Test("Id of a subview", arguments: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    func getId(subviewsCount: Int) {
        viewModel.subviewsCount = subviewsCount
        
        var previousId: Int = -1
        var currentId: Int
        for loopIndex in 0...2 {
            for index in 0..<viewModel.subviewsCount {
                currentId = viewModel.getId(loopIndex: loopIndex, index: index)
                #expect(currentId == previousId + 1)
                previousId = currentId
            }
        }
    }
    
    @Test("Set the scroll position", arguments: zip([
        4, 5, 6, 7, 6
    ], [
        4, 4, 4, 4, 0
    ]))
    func setScrollPosition(position: Int, subviewsCount: Int) {
        viewModel.subviewsCount = subviewsCount
        viewModel.scrollPosition = Int.random(in: 1...10)
        let randomPageIndex: Int? = Int.random(in: 1...10)
        var pageIndexValue: Int? = randomPageIndex
        
        viewModel.setScrollPosition(
            position,
            pageIndex: Binding {
                pageIndexValue
            } set: {
                pageIndexValue = $0
            }
        )
        
        #expect(viewModel.scrollPosition == position)
        if subviewsCount != 0 {
            #expect(pageIndexValue == position % subviewsCount)
        } else {
            #expect(pageIndexValue == randomPageIndex)
        }
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
            viewModel.scrollPosition = scrollPosition.initialPosition
            
            viewModel.onScrollPhaseChange(.idle)
            
            #expect(viewModel.isDragActive)
            #expect(viewModel.isAutoScrollingEnabled == isAutoScrollingEnabled)
            #expect(viewModel.isAutoScrollingAllowed)
            #expect(viewModel.scrollPosition ==  scrollPosition.positionAfterComputations)
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
        AutoScrolling(isEnabled: true, isAllowed: true, pauseDuration: 0.1, direction: .leftToRight),
        AutoScrolling(isEnabled: false, isAllowed: false, pauseDuration: 0.3, direction: .rightToLeft),
    ])
    func onChangeOfAutoScrolling(autoScrolling: AutoScrolling) {
        viewModel.isAutoScrollingEnabled = Bool.random()
        viewModel.isAutoScrollingAllowed = Bool.random()
        viewModel.autoScrollPauseDuration = Double.random(in: 0...1)
        viewModel.autoScrollDirection = .allCases.randomElement()!
        
        viewModel.onChangeOfAutoScrolling(
            isEnable: autoScrolling.isEnabled,
            isAllowed: autoScrolling.isAllowed,
            pauseDuration: autoScrolling.pauseDuration,
            direction: autoScrolling.direction
        )
        
        #expect(viewModel.isAutoScrollingEnabled == autoScrolling.isEnabled)
        #expect(viewModel.isAutoScrollingEnabled == autoScrolling.isAllowed)
        #expect(viewModel.autoScrollPauseDuration == autoScrolling.pauseDuration)
        #expect(viewModel.autoScrollDirection == autoScrolling.direction)
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
