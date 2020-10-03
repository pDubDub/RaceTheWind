//
//  Cloud.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 9/21/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import Foundation
import SpriteKit

class Cloud: SKSpriteNode {

    var isDriftingRight: Bool = true

    init() {
        let texture = SKTexture(imageNamed: "cloud_v2")
        super.init(texture: texture, color: .white, size: texture.size())
        name = "Cloud"

        zPosition = 50

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        position = CGPoint(x: size.width/2, y: size.height/3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init()")
    }

}
