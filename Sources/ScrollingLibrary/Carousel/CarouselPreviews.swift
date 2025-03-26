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
    @State private var autoScrollingEnabled: Bool = true
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

#Preview("0, 1 or 2 elements") {
    VStack {
        // If there is no element then the scrollView is not visible
        CarouselPreview(itemsCount: 0) {
            Carousel {
                
            }
        }
        
        Divider()
        
        // If there is one element then the scrolling is disable
        CarouselPreview(itemsCount: 1) {
            Carousel {
                Color.red
                    .frame(height: 100)
            }
        }
        
        Divider()
        
        // If there is more than 1 element then it is the default behaviour.
        CarouselPreview(itemsCount: 2) {
            Carousel {
                Group {
                    Color.red
                    Color.blue
                }
                .frame(height: 100)
            }
        }
    }
}

struct TestModel: Identifiable {
    let id = UUID()
    let color: Color
}

#Preview("Init") {
    
    ScrollView {
        Text("Default init").font(.title2)
        CarouselPreview(itemsCount: 2) {
            Carousel {
                Group {
                    Color.red
                    Color.blue
                }
                .frame(height: 100)
            }
        }
        .padding(.bottom, 50)
        
        Text("Default init with a combination of view and forEach").font(.title2)
        CarouselPreview(itemsCount: 3) {
            let colors = [Color.blue, Color.green]
            Carousel {
                Color.red
                    .frame(height: 100)
                
                ForEach(colors.indices, id: \.self) { index in
                    colors[index]
                        .frame(height: 100)
                }
            }
        }
        .padding(.bottom, 50)
        
        Text("ForEach Data, ID init style with indexes").font(.title2)
        CarouselPreview(itemsCount: 3) {
            let colors = [Color.red, Color.blue, Color.green]
            Carousel(colors.indices, id: \.self) { index in
                colors[index]
                .frame(height: 100)
            }
        }
        .padding(.bottom, 50)
        
        Text("ForEach Data, ID init style with value").font(.title2)
        CarouselPreview(itemsCount: 4) {
            let colors = [Color.red, Color.blue, Color.green, Color.yellow]
            Carousel(colors, id: \.self) { color in
                color
                    .frame(height: 100)
            }
        }
        .padding(.bottom, 50)
        
        Text("ForEach Data, init style").font(.title2)
        CarouselPreview(itemsCount: 5) {
            let colors = [
                TestModel(color: Color.red),
                TestModel(color: Color.blue),
                TestModel(color: Color.green),
                TestModel(color: Color.yellow),
                TestModel(color: Color.orange),
            ]
            Carousel(colors) { color in
                color.color
                    .frame(height: 100)
            }
        }
    }
}

#Preview("Constrain width") {
    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
    
    ScrollView {
        Text("Constraint scrollView but full width item").font(.title2)
        CarouselPreview(itemsCount: colors.count) {
            Carousel(colors, id: \.self) { color in
                color
                    .frame(height: 100)
            }
            .frame(width: 200)
            .background(.black)
            .border(.yellow)
        }
        .padding(.bottom, 50)
        
        Text("Full width scrollView but constraint item").font(.title2)
        CarouselPreview(itemsCount: 4) {
            Carousel(colors, id: \.self) { color in
                color
                    .frame(width: 200, height: 100)
            }
            .background(.black)
            .border(.yellow)
        }
        .padding(.bottom, 50)
        
        Text("Padding").font(.title2)
        CarouselPreview(itemsCount: colors.count) {
            Carousel(colors, id: \.self) { color in
                color
                    .frame(height: 100)
                    .padding(.horizontal, 50)
            }
            .background(.black)
            .border(.yellow)
        }
    }
}

#if os(visionOS)
#Preview("visionOS", windowStyle: .automatic) {
        CarouselPreview(itemsCount: 4) {
            let colors = [Color.red, Color.blue, Color.green, Color.yellow]
            Carousel(colors, id: \.self) { color in
                color
                    .frame(height: 100)
            }
            .border(.black)
        }
}
#else
#Preview("Simple") {
        CarouselPreview(itemsCount: 4) {
            let colors = [Color.red, Color.blue, Color.green, Color.yellow]
            Carousel(colors, id: \.self) { color in
                color
                    .frame(height: 100)
            }
            .border(.black)
        }
}
#endif

// TODO: add style
//#Preview {
//    let colors = [Color.red, Color.blue, Color.green, Color.yellow]
//    
//    CarouselPreview(itemsCount: colors.count) {
//        let carouselWidth: CGFloat = UIScreen.main.bounds.width
//        let with: CGFloat = 250
//        let widthDiff: CGFloat = carouselWidth - with
//        Carousel {
//            ForEach(colors.indices, id: \.self) { index in
//                ZStack {
//                    colors[index]
//                    Text("Index: \(index)")
//                        .foregroundStyle(.white)
//                }
//                .frame(width: with, height: 350)
//                .padding(.horizontal, widthDiff / 2)
//            }
//        }
//    }
//}
