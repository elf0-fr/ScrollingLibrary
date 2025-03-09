//
//  DotIndicatorViewModelTests.swift
//  ScrollingLibrary
//
//  Created by Elfo on 08/03/2025.
//

import Testing
@testable import ScrollingLibrary

@MainActor struct DotIndicatorViewModelTests {
    
    @Test("Is the dot at index selected") func isSelected() async throws {
        let viewModel = DotsIndicatorViewModel()
        viewModel.itemsCount = 5
        #expect(viewModel.isSelected(index: 4, scrollPosition: 4))
        
        #expect(!viewModel.isSelected(index: 4, scrollPosition: 3), "Scroll position is different than index, so return false")
        
        #expect(!viewModel.isSelected(index: 5, scrollPosition: 3), "Index out of bounds, so return false")
    }
}
