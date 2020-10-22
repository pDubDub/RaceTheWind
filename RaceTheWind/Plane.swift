//
//  Plane.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 9/21/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import Foundation
import SpriteKit

class Plane: SKSpriteNode {

    var throttle: CGFloat = 0

    var minAirspeed: CGFloat = 75
    var maxAirspeed: CGFloat = 400

    var altitude: Int = 10

    init() {
        let texture = SKTexture(imageNamed: "GeeBee100")
        super.init(texture: texture, color: .white, size: texture.size())
        name = "Racer"
        
        zPosition = 20

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        position = CGPoint(x: size.width/2, y: size.height/3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init()")
    }
}
