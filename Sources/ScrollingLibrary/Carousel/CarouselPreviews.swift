//
//  CarouselPreviews.swift
//  ScrollingLibrary
//
//  Created by Elfo on 13/03/2025.
//

import SwiftUI

struct CarouselPreview<Content: View>: View {
    let itemsCount: Int
    @ViewBuilder var content: Content
    
    @State private var pageIndex: Int?
    @State private var autoScrollingEnabled: Bool = false
    @State private var rightToLeft: Bool = false
    @State private var autoScrollPauseDuration: Double = 3
    
    var body: some View {
        VStack {
            GroupBox {
                Toggle("Enable auto scrolling", isOn: $autoScrollingEnabled)
                Toggle("\(rightToLeft ? "Right to Left" : "Left to Right")", isOn: $rightToLeft)
                Stepper("Pause Duration: \(autoScrollPauseDuration.formatted())", value: $autoScrollPauseDuration, in: 1...5)
            }
            
            content
                .pageIndex($pageIndex)
                .autoScrollingEnabled(autoScrollingEnabled)
                .autoScrollPauseDuration(autoScrollPauseDuration)
                .autoScrollDirection(rightToLeft ? .rightToLeft : .leftToRight)
                .overlay(alignment: .bottom) {
                    DotsIndicator(scrollPosition: $pageIndex, itemsCount: itemsCount)
                        .padding(.bottom)
                }
            
            Spacer()
        }
    }
}

#Preview("Edge to edge") {
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    CarouselPreview(itemsCount: colors.count) {
        
        Carousel {
            ForEach(colors.indices, id: \.self) { index in
                ZStack {
                    colors[index]
                    Text("Index: \(index)")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(width: UIScreen.main.bounds.width, height: 350)
            }
        }
        
    }
}

#Preview("Constrain width") {
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    CarouselPreview(itemsCount: colors.count) {
        
        let carouselWidth: CGFloat = 300
        let with: CGFloat = 200
        let widthDiff: CGFloat = carouselWidth - with
        Carousel {
            ForEach(colors.indices, id: \.self) { index in
                ZStack {
                    colors[index]
                    Text("Index: \(index)")
                        .foregroundStyle(.white)
                }
                .frame(width: with, height: 250)
                .padding(.horizontal, widthDiff / 2)
            }
        }
        .frame(width: carouselWidth)
        .background(.black)
        .border(.yellow)
        
    }
}

// TODO: add style
#Preview {
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    CarouselPreview(itemsCount: colors.count) {
        let carouselWidth: CGFloat = UIScreen.main.bounds.width
        let with: CGFloat = 250
        let widthDiff: CGFloat = carouselWidth - with
        Carousel {
            ForEach(colors.indices, id: \.self) { index in
                ZStack {
                    colors[index]
                    Text("Index: \(index)")
                        .foregroundStyle(.white)
                }
                .frame(width: with, height: 350)
                .padding(.horizontal, widthDiff / 2)
            }
        }
    }
}
