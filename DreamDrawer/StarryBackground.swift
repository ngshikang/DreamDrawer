//
//  SpaceBackground.swift
//  DreamDrawer
//
//  Created by David Wang on 2024-04-13.
//

import Foundation
import SwiftUI

struct Star {
    var position: CGPoint
    var yVelocity: CGFloat
    var xVelocity: CGFloat
    var size: CGSize
}

struct StarryBackground: View{
    @State private var stars: [Star] = []
    let timer = Timer.publish(every: 0.01, on: .main, in: .common)
        .autoconnect()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    var body: some View {
        Canvas { context, size in
            for star in stars {
                var contextCopy = context
                let rect = CGRect(x: star.position.x, y: star.position.y, width: star.size.width, height: star.size.height)
                contextCopy.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
        .background(Color.black)
        .onAppear{
            for _ in 0..<100 {
                let size = CGFloat.random(in: 1...3)
                let star = Star(position: CGPoint(x: CGFloat.random(in: 0...screenWidth),
                                                  y:CGFloat.random(in: 0...screenHeight)),
                                yVelocity: CGFloat.random(in: 1...5),
                                xVelocity: 0,
                                size: CGSize(width: size, height: size*(2+size/5))
                )
                stars.append(star)
            }
        }
        .onReceive(timer) { _ in
            for i in 0..<stars.count {
                stars[i].position.y += stars[i].yVelocity
                stars[i].position.x += stars[i].xVelocity
                if stars[i].position.y > screenHeight {
                    stars[i].position = CGPoint(x: CGFloat.random(in: 0...screenWidth), y:0)
                    let size = CGFloat.random(in: 1...3)
                    stars[i].size = CGSize(width: size, height: size*(2+size/5))
                }
            }
                                
        }
            
    }
}
