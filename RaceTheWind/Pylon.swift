//
//  Pylon.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 10/02/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import Foundation
import SpriteKit

class Pylon: SKSpriteNode {

    enum Side {
        case left
        case right
    }

    var resetY: CGFloat = 0
    var minLeft: CGFloat = 0
    var maxRight: CGFloat = 0

    init(side: Side) {
        let texture: SKTexture

        if side == .left {
            texture = SKTexture(imageNamed: "pylon_L")
//            name = "left"
        } else {
            texture = SKTexture(imageNamed: "pylon_R")
//            name = "right"
        }

        super.init(texture: texture, color: .white, size: texture.size())

        name = side == .left ? "left" : "right"
        zPosition = 10

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        position = CGPoint(x: size.width/2, y: size.height/3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init()")
    }

    func update(by distanceThisUpdate: CGFloat, otherPylonX: CGFloat) {
        if position.y <= 0 - size.height {
            // then move back to top of screen
            position.y = resetY

            // ...and random x
            if name == "left" {
                position.x = CGFloat.random(in: (minLeft) ... (otherPylonX))
            } else {
                position.x = CGFloat.random(in: (otherPylonX) ... (maxRight))
            }
            // TODO - there is an occasional error, I think when the otherPylonX value is beyond the min/max value

            // then decerement the pylon number

            // if pylon number is 1, then set texture to END
        }
        position.y = position.y - distanceThisUpdate
    }
    
}
