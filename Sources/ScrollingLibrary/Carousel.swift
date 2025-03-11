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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.autoScrollingEnabled) private var autoScrollingEnabled
    @Environment(\.autoScrollPauseDuration) private var autoScrollPauseDuration

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
                        
                        // auto scrolling settings
                        viewModel.isAutoScrollingEnabled = autoScrollingEnabled
                        viewModel.autoScrollPauseDuration = autoScrollPauseDuration
                    }
                    .onDisappear {
                        viewModel.autoScrollTask?.cancel()
                    }
            }
        }
        .scrollPosition(id: $viewModel.internalScrollPosition)
        .scrollDisabled(!viewModel.isDragActive)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always)
        .scrollTargetBehavior(.paging)
        .onScrollPhaseChange { viewModel.onScrollPhaseChange($1) }
        .onChange(of: autoScrollingEnabled) { viewModel.onChangeOfAutoScrolling(isEnable: $1)}
        .onChange(of: autoScrollPauseDuration) { viewModel.onChangeOfAutoScrolling(pauseDuration: $1) }
        .onChange(of: viewModel.isAutoScrollingAllowed) { viewModel.onChangeOfAutoScrolling(isAllowed: $1) }
        .onChange(of: scenePhase) { viewModel.onChangeOfScenePhase($1) }
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
    
    var isAutoScrollingEnabled: Bool = true
    var isAutoScrollingAllowed: Bool = false
    var autoScrollPauseDuration: Double = 3
    var autoScrollTask: Task<(), Never>?
    
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
        if let internalScrollPosition {
            if internalScrollPosition < subviewsCount {
                self.internalScrollPosition = internalScrollPosition + subviewsCount
            } else if internalScrollPosition >= subviewsCount * 2 {
                self.internalScrollPosition = internalScrollPosition - subviewsCount
            }
        } else {
            self.internalScrollPosition = subviewsCount
        }
    }
    
    func onChangeOfAutoScrolling(
        isEnable: Bool? = nil,
        isAllowed: Bool? = nil,
        pauseDuration: Double? = nil
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
                self.internalScrollPosition = (internalScrollPosition ?? subviewsCount - 1) + 1
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

#Preview {
//        @Previewable @State var scrollPosition: Int?
    @Previewable @State var autoScrollingEnabled: Bool = false
    @Previewable @State var autoScrollPauseDuration: Double = 3
    
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    VStack {
        GroupBox {
            Toggle("Enable auto scrolling", isOn: $autoScrollingEnabled)
            Stepper("Pause Duration: \(autoScrollPauseDuration.formatted())", value: $autoScrollPauseDuration, in: 1...5)
        }
        
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
        .autoScrollingEnabled(autoScrollingEnabled)
        .autoScrollPauseDuration(autoScrollPauseDuration)
        .frame(width: 300)
        .background {
            RoundedRectangle(cornerRadius: 25)
        }
    }
}
