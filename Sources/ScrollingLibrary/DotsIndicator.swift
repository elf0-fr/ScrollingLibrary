//
//  DotsIndicator.swift
//  ScrollingLibrary
//
//  Created by Elfo on 05/03/2025.
//

import SwiftUI

public struct DotsIndicator: View {
    
    @Binding var scrollPosition: Int?
    
    @State private var viewModel = DotsIndicatorViewModel()
    
    public init(scrollPosition: Binding<Int?>, itemsCount: Int) {
        self._scrollPosition = scrollPosition
        viewModel.itemsCount = itemsCount
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<viewModel.itemsCount, id: \.self) { index in
                Button {
                    updateScrollPosition(index: index)
                } label: {
                    Circle()
                        .fill(.thickMaterial.opacity(viewModel.isSelected(index: index, scrollPosition: scrollPosition) ? 0.8 : 0.3))
                        .frame(width: 15)
                        .padding(5)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func updateScrollPosition(index: Int) {
        withAnimation {
            scrollPosition = index
        }
    }
}

@Observable @MainActor
class DotsIndicatorViewModel {
    var itemsCount: Int = 0
    
    func isSelected(index: Int, scrollPosition: Int?) -> Bool {
        index == (scrollPosition ?? 0) % itemsCount
    }
}

#Preview {
    @Previewable @State var scrollPosition: Int?
    DotsIndicator(scrollPosition: $scrollPosition, itemsCount: 5)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.linearGradient(colors: [.blue, .red], startPoint: .leading, endPoint: .trailing))
        }
}

#Preview {
    @Previewable @State var scrollPosition: Int? = 5
    ScrollView {
        Text("Hello, World! \(scrollPosition ?? 0)")
            .foregroundStyle(.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 25)
            }
    }
    .scrollPosition(id: $scrollPosition)
}
