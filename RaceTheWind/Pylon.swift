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

    var resetY: CGFloat = 0         // I don't think I use this anymore, using screenSize var instead
    var minLeft: CGFloat = 0
    var maxRight: CGFloat = 0
    var screenSize: CGFloat = 0

    var number: Int = 0

    var isPassed: Bool = false
    var isFirstPylon: Bool = false              // TODO - will be used to start timer
    var isLastPylon: Bool = false               // TODO - will be used to change texture, stop timer, end game, stop pylon respawning

    let flybySound: SKAction = SKAction.playSoundFileNamed("s6b_pass.caf", waitForCompletion: false)

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

    /// To be run each frame by GameScene. Resets pylons to top of screen. Updates position each frame. Responds to racer passing pylons.
    /// - Parameters:
    ///   - distanceThisUpdate: How many pixels the background moves this frame/update.
    ///   - otherPylon: The location of the other pylon, to determine range of restart x locations.
    ///   - racerAt: The location of the racer, to determine if and how the racer passes a pylon.
    /// - Returns:
    ///   - returns string "GOOD" or "MISS" when a pylon is passed.
    func update(by distanceThisUpdate: CGFloat, otherPylon: CGPoint,  racerAt: CGPoint) -> String {

        if (name == "left" && number >= 2) || (name == "right" && number >= 1) {
            if position.y <= 0 - size.height {
                // then move back to top of screen
    //            position.y = resetY
                position.y = otherPylon.y + screenSize * 0.6        // this gives more consistent spacing regardless of speeds
                isPassed = false

                // ...and random x
                if name == "left" {
                    position.x = CGFloat.random(in: (minLeft) ... (otherPylon.x + 50))
                    texture = SKTexture(imageNamed: "pylon_L")
                } else {
                    position.x = CGFloat.random(in: (min(maxRight - 100, otherPylon.x - 50)) ... (maxRight))
                    texture = SKTexture(imageNamed: "pylon_R")
                }
                // TODO - there is an occasional error, I think when the otherPylonX value is beyond the min/max value

                // then decerement the pylon number

                // if pylon number is 1, then set texture to END

                print("Reseting the \(String(describing: self.name)) pylon is number \(number)")
            }
        }
        position.y = position.y - distanceThisUpdate

        // add pass detection
        if !isPassed && position.y < racerAt.y {
            print("Passed pylon \(number)")
            isPassed = true
            // play flyby sound
            run(flybySound)
            // TODO - might be really cool if we could alter sound a little based on speed and how close you pass to the pylon

            number -= 2

            // change textures and return string for scoring
            if (name == "left" && racerAt.x < position.x) || (name == "right" && racerAt.x > position.x) {
                texture = SKTexture(imageNamed: "pylon_OK")
                // play a "GOOD" sound?
                return "GOOD"
            } else {
                texture = SKTexture(imageNamed: "pylon_MISS")
                // play a "MISS" sound!
                return "MISS"
            }
        } else {
            return ""
        }
    }
    
}
