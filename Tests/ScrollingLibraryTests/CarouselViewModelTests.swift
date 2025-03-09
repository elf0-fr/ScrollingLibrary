//
//  CarouselViewModelTests.swift
//  ScrollingLibrary
//
//  Created by Elfo on 08/03/2025.
//


import Testing
@testable import ScrollingLibrary

@MainActor struct CarouselViewModelTests {
    let viewModel = CarouselViewModel()
        
    @Test("Id of a subview") func getId() {
        #expect(CarouselViewModel.getId(loopIndex: 0, index: 1) == 1)
        #expect(CarouselViewModel.getId(loopIndex: 1, index: 2) == 6)
        #expect(CarouselViewModel.getId(loopIndex: 2, index: 3) == 11)
    }
    
    @Test("Get scroll position [0, subviewsCount[") func getScrollPosition() {
        viewModel.subviewsCount = 5
        
        viewModel.internalScrollPosition = 5
        #expect(viewModel.scrollPosition == 0)
        
        viewModel.internalScrollPosition = 7
        #expect(viewModel.scrollPosition == 2)
        
        viewModel.internalScrollPosition = 9
        #expect(viewModel.scrollPosition == 4)
        
        viewModel.internalScrollPosition = 2
        #expect(viewModel.scrollPosition == 2)
    }
    
    @Test("Set scroll position [0, subviewsCount[") func setScrollPosition() {
        viewModel.subviewsCount = 5
        
        viewModel.internalScrollPosition = 5
        viewModel.scrollPosition = 2
        #expect(viewModel.internalScrollPosition == 7)
        
        viewModel.internalScrollPosition = 7
        viewModel.scrollPosition = 0
        #expect(viewModel.internalScrollPosition == 5)
        
        viewModel.internalScrollPosition = 9
        viewModel.scrollPosition = 2
        #expect(viewModel.internalScrollPosition == 7)
        
        viewModel.internalScrollPosition = 2
        viewModel.scrollPosition = 4
        #expect(viewModel.internalScrollPosition == 9)
    }
    
    @Test("Scroll phase change to idle") func onScrollPhaseChange_idle() {
        viewModel.subviewsCount = 5
        viewModel.internalScrollPosition = 2
        viewModel.isDragActive = false
        viewModel.onScrollPhaseChange(.idle)
        #expect(viewModel.isDragActive)
        #expect(viewModel.internalScrollPosition == 2 + 5)
        
        viewModel.subviewsCount = 5
        viewModel.internalScrollPosition = 10
        viewModel.isDragActive = false
        viewModel.onScrollPhaseChange(.idle)
        #expect(viewModel.isDragActive)
        #expect(viewModel.internalScrollPosition == 10 - 5)
        
        viewModel.isDragActive = true
        viewModel.onScrollPhaseChange(.idle)
        #expect(viewModel.isDragActive)
    }
    
    @Test("Scroll phase change to decelerating") func onScrollPhaseChange_decelerating() {
        viewModel.isDragActive = true
        viewModel.onScrollPhaseChange(.decelerating)
        #expect(!viewModel.isDragActive)
        
        viewModel.isDragActive = false
        viewModel.onScrollPhaseChange(.decelerating)
        #expect(!viewModel.isDragActive)
    }
}
