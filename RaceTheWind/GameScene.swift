//
//  GameScene.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 12/24/19.
//  Copyright © 2019 Patrick Wheeler. All rights reserved.
/*
    Race The Wind is a port from Python to Swift/iOS of a simple air racing slalom game that I built for CIS151.
    Loosely inspired byan old Atari 2600 game of air racing slalom called Sky Jinks.
 */

import SpriteKit
import CoreGraphics

class GameScene: SKScene {

    let playableWidth: CGFloat
    let leftMargin: CGFloat

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0

    let landscape = SKSpriteNode(imageNamed: "field2048")
    let racer = Plane()
    let cloud = Cloud()                                 // Does Cloud really need to be its own class. I'm thinking maybe not?



//    let playableRect: CGRect
    let yoke = SKShapeNode(circleOfRadius: 60)
    var lastTouch: CGPoint

    var airspeedPointsPerSec: CGPoint = CGPoint(x: 0, y: 200.0)

    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        playableWidth = size.height / maxAspectRatio
        leftMargin = (size.width-playableWidth)/2.0
//        let playableMargin = (size.width-playableWidth)/2.0
//        playableRect = CGRect(x: 0, y: playableMargin,
//                              width: playableWidth,
//                              height: size.height)
        print("Size.height is \(size.height) so the playable width is \(playableWidth) so the missing left margin is \(leftMargin) pixels wide.")

        // TODO - maybe what we want to do, is make the upper 3:4 section of the iphone screen the playable area, leaving the bottom for control only
        //    But then the ipad we can drop that bottom margin.

        lastTouch = CGPoint(x: size.width/2, y: 200)


        super.init(size: size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        // good place for initial setup
        backgroundColor = SKColor.black

        landscape.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        landscape.position = CGPoint(x: size.width/2, y: 0)
        landscape.zPosition = -1
        addChild(landscape)

//        racer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        racer.position = CGPoint(x: size.width/2, y: lastTouch.y + airspeedPointsPerSec.y)
//        racer.scale(to: CGSize(width: 2.0, height: 2.0))          // seems to make sprite just disappear
        addChild(racer)

        cloud.position.x = CGFloat.random(in: (leftMargin) ... (leftMargin + playableWidth))
        print(cloud.position.x)
        // TODO - usavble iPhone screen ranges from about 600 to 1400. We might need usable rect formulae above after all.

        cloud.position.y = size.height + cloud.size.height
        addChild(cloud)

        addChild(yoke)

//        print(size.height)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        // delta-t
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        // control
        yoke.position = lastTouch

        // move racer
        racer.position.x = yoke.position.x

        // TODO - change all of these 100, 200 numbers to percentages of the screen height
        // throttle based on touch.y
//        racer.throttle = min(max((yoke.position.y - 200), 0), 400) / 400
        racer.throttle = min(max(yoke.position.y / (size.height/2), 0.10), 1.0)
        // move airspeed towards throttle
        let change : CGFloat = ((racer.throttle * 400) - airspeedPointsPerSec.y) / 10
        airspeedPointsPerSec.y += change
        if airspeedPointsPerSec.y < 50 {
            airspeedPointsPerSec.y = 50
        } else if airspeedPointsPerSec.y > 400 {
            airspeedPointsPerSec.y = 400
        }

        print("touch.y: \(lastTouch.y) yields throttle of \(racer.throttle) and the airspeed is now \(airspeedPointsPerSec.y)")

        racer.position.y = 2 * airspeedPointsPerSec.y + 200

        // move landscape
        landscape.position = CGPoint(x: landscape.position.x,
                                     y: landscape.position.y - (2 * airspeedPointsPerSec.y * CGFloat(dt)))
        if landscape.position.y <= -landscape.size.height/2 {
            landscape.position.y -= landscape.position.y
//            print("background reset")
        }

        // Move cloud. This used to be a class method in Python version.
        cloud.position.y = cloud.position.y - (2 * airspeedPointsPerSec.y * CGFloat(dt))
        if cloud.isDriftingRight {
            cloud.position.x += 1
        } else {
            cloud.position.x -= 1
        }
        if cloud.position.y <= 0 - cloud.size.height {
            cloud.position.x = CGFloat.random(in: (leftMargin) ... (leftMargin + playableWidth))
            cloud.position.y = size.height + cloud.size.height
            if cloud.position.x < leftMargin + playableWidth/4 {
                // if cloud starts on the left, drift right
                cloud.isDriftingRight = true
            } else if cloud.position.x > leftMargin + playableWidth * 0.75 {
                // if starts on right, drift left
                cloud.isDriftingRight = false
            } else {
                // else random
                cloud.isDriftingRight = Int.random(in: 1 ... 2) == 1 ? true : false
                print(cloud.isDriftingRight)
            }
        }
    }

    func move(sprite: SKSpriteNode, airspeed: CGPoint) {
        // should borrow move methodology from zombies
    }


    // I kind of think the template drawn graphics that follow the mouse might be cool to use somehow
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
//

/*      Perhaps we can have 4 or more different control options:
            1 - plane matches touches
            2 - plane goes to touch (like the Python version)
            3 - yoke determins whether plane goes left or right (i.e. plane goes left if yoke is left)
            4 - yoke determines bank, which in turn determines direction (have to yoke left if banked right to level out)

        ...and for double the options, yoke could be set by either touch or tilt!
*/
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }

        lastTouch = pos
        print(lastTouch)
    }
//
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
        lastTouch = pos
        print(lastTouch)
    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
//
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//

}
