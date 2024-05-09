//
//  GameScene.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 12/24/19.
//  Copyright © 2019 Patrick Wheeler. All rights reserved.
/*
    Race The Wind is a port of a simple air racing slalom game that I built for CIS151 from Python to Swift/iOS.
    Loosely inspired by an old Atari 2600 game of air racing slalom called Sky Jinks.
 */

import SpriteKit
import CoreGraphics
import CoreMotion
import AVFoundation

class GameScene: SKScene {

    let playableWidth: CGFloat
    let leftMargin: CGFloat

    let speedometerLabel: SKLabelNode = SKLabelNode()
    let pylonCountLabel: SKLabelNode = SKLabelNode()
    let pylonMissLabel:SKLabelNode = SKLabelNode()

    let bestTimeLabel: SKLabelNode = SKLabelNode()
    let elapsedTimeLabel: SKLabelNode = SKLabelNode()
    let differenceLabel: SKLabelNode = SKLabelNode()

    var gameplayButton: TouchableButtonNode = TouchableButtonNode()
    // subclass of SKLabelNode that can easily detect touches.
//    let gameplayButtonLabel: TouchLabelNode = TouchLabelNode(text: "TAP HERE TO BEGIN")
    let gameplayButtonLabel: SKLabelNode = SKLabelNode(text: "TAP HERE TO BEGIN")
    let finishLine: SKTexture = SKTexture(imageNamed: "checker")

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
//    let recordsManager = BestTimesManager()

    var startTime: TimeInterval = 0             // for run timing
    var currentTime: TimeInterval = 0
    var elapsedRunTime: TimeInterval = 0
    var bestTime: TimeInterval = 0
    var timeDifference: TimeInterval = 0

    var isInitiallyPaused: Bool = true
    var clockIsRunning: Bool = false
    var pylonsAreRunning: Bool = false
    var didPassFirstPylon: Bool = false
    var didPassLastPylon: Bool = false
    var runComplete: Bool = false

    var airspeedPointsPerSec: CGPoint = CGPoint(x: 0, y: 200.0)
    var distanceThisUpdate: CGFloat = 0

    var newAirspeed: CGFloat = 150
    var newHeading: CGFloat = 0
    var newDistancePerUpate: CGFloat = 0
    var newVelocity: CGPoint = CGPoint.zero
    var newThrottle: CGFloat = 0
    var newPower: CGFloat = 0
    var newDrag: CGFloat = 0

    let landscape = SKSpriteNode(imageNamed: "field2048")
    let racer = Plane()
    let racerShadow = SKSpriteNode(imageNamed: "GeeBee100_shadow")
    let cloud = Cloud()                                         // Cloud is own class only because of drift boolean property.
    let cloudShadow = SKSpriteNode(imageNamed: "cloud_v2_shadow")

    let leftPylon = Pylon(side: .left)
    let rightPylon = Pylon(side: .right)

    var leftJudge: String = ""
    var rightJudge: String = ""
    var pylonsRemaining: Int = 10
    var pylonsMissed: Int = 0

//    let playableRect: CGRect
    // HUD-UI
    // TODO - replace these literals with percentages of screen size
    let yoke = SKShapeNode(circleOfRadius: 60)
    var previousYoke: CGPoint
    var lastTouch: CGPoint
    let tilt = SKShapeNode(circleOfRadius: 20)
    let ruddderIndicator = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 50), cornerRadius: 2)
    let rudderStopLeft = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 20), cornerRadius: 2)
    let rudderStopRight = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 20), cornerRadius: 2)
    let throttleIndicator = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 50, height: 10), cornerRadius: 2)
    let throttleStopFull = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 10), cornerRadius: 2)
    let throttleStopIdle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 10), cornerRadius: 2)


    var motionManager: CMMotionManager!

    let spaceForNotch: CGFloat = 100
    // used to move labels at top of the screen down a little bit. In theory, we could choose to apply it only if device has notch.
   
    
    var sampleSetting: Int = 0
    let storyboard: UIStoryboard
    let settingsViewController: SettingsViewController

    override init(size: CGSize) {
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        print("UIScreen height is \(screenHeight) and width is \(screenWidth)")
        
        
//        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatio: CGFloat = screenHeight/screenWidth
        // adding aspect ratio determined by actual screen size fixed label positioning
        
        playableWidth = size.height / maxAspectRatio
        leftMargin = (size.width-playableWidth)/2.0
//        let playableMargin = (size.width-playableWidth)/2.0
//        playableRect = CGRect(x: 0, y: playableMargin,
//                              width: playableWidth,
//                              height: size.height)
        print("GameScene height is \(size.height) and width is \(size.width)")
//        This is the size of the gameScene, which is defined when initiated in GameViewController.
//        It is not the actual screen size.
        
      
        
        
        print("Size.height is \(size.height) so the playable width is \(playableWidth) so the missing left margin is \(leftMargin) pixels wide.")
        print("Full width is \(size.width)")

        // TODO - maybe what we want to do, is make the upper 3:4 section of the iphone screen the playable area, leaving the bottom for control only
        //    But then the ipad we can drop that bottom margin.

        lastTouch = CGPoint(x: size.width/2, y: 200)
        previousYoke = lastTouch

        storyboard = UIStoryboard(name: "SettingsView", bundle: nil)
        settingsViewController = (storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController)!

        super.init(size: size)
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        // good place for initial setup
//        backgroundColor = SKColor.black
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
//        motionManager.stopGyroUpdates()

        landscape.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        landscape.position = CGPoint(x: size.width/2, y: 0)
        landscape.zPosition = -1
        addChild(landscape)

//        racer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        racer.position = CGPoint(x: size.width/2, y: lastTouch.y + airspeedPointsPerSec.y)
        racer.scale(to: CGSize(width: 100 * (playableWidth / 600), height: 72 * (playableWidth / 600)))
            // TODO - should factor out this scaling function, so that we can apply it to everything.
            // Or perhaps we just move the camera node closer?
        addChild(racer)

        racerShadow.position.x = racer.position.x + 40
        racerShadow.position.y = racer.position.y - 40
        racerShadow.scale(to: CGSize(width: 100 * (playableWidth / 600), height: 72 * (playableWidth / 600)))
        addChild(racerShadow)

        // cloud setup
        cloud.position.x = CGFloat.random(in: (leftMargin) ... (leftMargin + playableWidth))
//        print(cloud.position.x)
        // TODO - usavble iPhone screen ranges from about 600 to 1400. We might need usable rect formulae above after all.

        cloud.position.y = size.height + cloud.size.height
        addChild(cloud)

        cloudShadow.position.x = cloud.position.x + 100
        cloudShadow.position.y = cloud.position.y - 100
        cloudShadow.zPosition = 1
        addChild(cloudShadow)

//        addChild(playableRect)

        leftPylon.position = CGPoint(x: leftMargin + playableWidth * 0.25, y: size.height + leftPylon.size.height)
        leftPylon.resetY = size.height + leftPylon.size.height
        leftPylon.minLeft = leftMargin + racer.size.width * 2
        leftPylon.maxRight = leftMargin + playableWidth - racer.size.width * 2
        leftPylon.screenSize = size.height
        leftPylon.number = pylonsRemaining
        addChild(leftPylon)

        rightPylon.position = CGPoint(x: leftMargin + playableWidth * 0.75, y: leftPylon.position.y + size.height/2 + rightPylon.size.height)
        rightPylon.resetY = size.height + rightPylon.size.height
        rightPylon.minLeft = leftMargin + racer.size.width * 2
        rightPylon.maxRight = leftMargin + playableWidth - racer.size.width * 2
        rightPylon.screenSize = size.height
        rightPylon.number = pylonsRemaining - 1
        addChild(rightPylon)

//        print(size.height)

        // HUD (UI)
        addChild(yoke)
        tilt.fillColor = UIColor(red: 0, green: 0, blue: 0.8, alpha: 0.2)
        addChild(tilt)

        ruddderIndicator.position.x = size.width/2
        ruddderIndicator.position.y = 0
        addChild(ruddderIndicator)
        rudderStopLeft.position.x = leftMargin + playableWidth * 0.1
        rudderStopLeft.position.y = 0
        addChild(rudderStopLeft)
        rudderStopRight.position.x = leftMargin + playableWidth * 0.9
        rudderStopRight.position.y = 0
        addChild(rudderStopRight)

        throttleIndicator.position.x = leftMargin
        throttleIndicator.position.y = size.height/2
        addChild(throttleIndicator)
        throttleStopFull.position.x = leftMargin
        throttleStopFull.position.y = size.height * 0.9
        addChild(throttleStopFull)
        throttleStopIdle.position.x = leftMargin
        throttleStopIdle.position.y = size.height * 0.1
        addChild(throttleStopIdle)

        //        for family in UIFont.familyNames.sorted() {
        //            let names = UIFont.fontNames(forFamilyName: family)
        //            print("Family: \(family) Font names: \(names)")
        //        }

        // NovaMono
        // https://fonts.google.com/specimen/Nova+Mono?category=Monospace&preview.text=12:45&preview.text_type=custom#license

//        guard let customFont = UIFont(name: "NovaMono", size: UIFont.labelFontSize) else {
//            fatalError("""
//                Failed to load the "NovaMono" font.
//                Make sure the font file is included in the project and the font name is spelled correctly.
//                """
//            )
//        }

        // time labels
        // load best times
        if let loadedBestTime = BestTimesManager.sharedTimesManager.getBestTime(forCourse: "One") {
            print("loaded best time found of \(loadedBestTime)")
            bestTime = loadedBestTime
            bestTimeLabel.text = String(format: "Best %.02f", bestTime)
        } else {
            bestTimeLabel.text = "Best --:--"
        }
        bestTimeLabel.fontName = "NovaMono"
        bestTimeLabel.fontSize = size.height * 0.02
        bestTimeLabel.fontColor = UIColor.white
        bestTimeLabel.horizontalAlignmentMode = .left
        bestTimeLabel.position = CGPoint(x: leftMargin + 0.5 * bestTimeLabel.fontSize, y: size.height - 1.5 * bestTimeLabel.fontSize - spaceForNotch)
        addChild(bestTimeLabel)

        elapsedTimeLabel.text = "5:00"
        elapsedTimeLabel.fontName = "NovaMono"
        elapsedTimeLabel.fontSize = size.height * 0.05
        elapsedTimeLabel.fontColor = UIColor.white
        elapsedTimeLabel.horizontalAlignmentMode = .right
//        print(bestTimeLabel.position.x)
//        print(elapsedTimeLabel.frame.width)
        elapsedTimeLabel.position = CGPoint(x: bestTimeLabel.position.x + elapsedTimeLabel.frame.width + 50, y: bestTimeLabel.position.y - elapsedTimeLabel.fontSize)
        // 50 was added to x position because it was cutting off anything from the 10's position or higher
        addChild(elapsedTimeLabel)

        differenceLabel.text = "(+0:00)"
        differenceLabel.fontName = "NovaMono"
        differenceLabel.fontSize = size.height * 0.02
        differenceLabel.fontColor = UIColor.white
        differenceLabel.horizontalAlignmentMode = .right
        differenceLabel.position = CGPoint(x: elapsedTimeLabel.position.x, y: elapsedTimeLabel.position.y - 1.2 * differenceLabel.fontSize)
        differenceLabel.isHidden = true
        addChild(differenceLabel)

        speedometerLabel.text = "100 mph"
        speedometerLabel.fontName = "NovaMono"
        speedometerLabel.fontSize = size.height * 0.03
        speedometerLabel.fontColor = UIColor.white
        speedometerLabel.horizontalAlignmentMode = .right
        print("Size of speedometer label is \(speedometerLabel.frame.width)")
        speedometerLabel.position = CGPoint(x: leftMargin + playableWidth - speedometerLabel.fontSize, y: 1.5 * speedometerLabel.fontSize)
        addChild(speedometerLabel)

        pylonCountLabel.text = "\(pylonsRemaining) pylons to go"
        pylonCountLabel.fontName = "NovaMono"
        pylonCountLabel.fontSize = size.height * 0.02
        pylonCountLabel.fontColor = UIColor.white
        pylonCountLabel.horizontalAlignmentMode = .right
        pylonCountLabel.position = CGPoint(x: leftMargin + playableWidth - pylonCountLabel.fontSize, y: bestTimeLabel.position.y)
        addChild(pylonCountLabel)

        pylonMissLabel.text = "\(pylonsMissed) missed"
        pylonMissLabel.fontName = "NovaMono"
        pylonMissLabel.fontSize = size.height * 0.02
        pylonMissLabel.fontColor = UIColor.white
        pylonMissLabel.horizontalAlignmentMode = .right
        pylonMissLabel.position = CGPoint(x: pylonCountLabel.position.x, y: pylonCountLabel.position.y - 1.5 * pylonMissLabel.fontSize)
        addChild(pylonMissLabel)

//        gameplayButton = TouchableButtonNode(rect: CGRect(x: 0, y: 0, width: rightPylon.frame.height * 16 , height: rightPylon.frame.height), cornerRadius: 20)
        gameplayButton = TouchableButtonNode(rect: CGRect(x: 0, y: 0, width: playableWidth * 0.8, height: rightPylon.frame.height), cornerRadius: 20)
        gameplayButton.position = CGPoint(x: leftMargin + playableWidth / 2 - gameplayButton.frame.width / 2,
                                      y: size.height / 5)
        gameplayButton.zPosition = 1
//        gameplayButton.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        gameplayButton.fillColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 0.5)

        addChild(gameplayButton)

        gameplayButtonLabel.fontName = "NovaMono"
        gameplayButtonLabel.fontSize = size.height * 0.02
        gameplayButtonLabel.fontColor = UIColor.white
        gameplayButtonLabel.horizontalAlignmentMode = .center
        gameplayButtonLabel.position = CGPoint(x: gameplayButton.frame.width / 2,
                                           y: gameplayButton.frame.height / 2 - gameplayButtonLabel.fontSize * 0.4 )
//            gameplayButtonLabel.zPosition = 52
        gameplayButton.addChild(gameplayButtonLabel)

        // Add a gesture recognizer for three-finger tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleThreeFingerTap(_:)))
        tapGesture.numberOfTouchesRequired = 3
        view.addGestureRecognizer(tapGesture)
        
//       simpleGameSceneFunc()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        // start/reset button
        if gameplayButton.wasTouched == true {
            print("Button has been touched")
            gameplayButton.wasTouched = false

            if isInitiallyPaused {
                print("Start game")
                isInitiallyPaused = false
//                gameplayButtonLabel.isHidden = true
                gameplayButton.position.y = rightPylon.resetY
//                gameplayButton.fillTexture = finishLine
                gameplayButtonLabel.fontColor = UIColor.white
                gameplayButtonLabel.horizontalAlignmentMode = .right
                gameplayButtonLabel.text = "FINISH LINE!"
                pylonsAreRunning = true
                print("  Start pylons")
            } else {
                resetGame()
            }
        }

        // Step 1: computer delta-t
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        // Step 2: determine control input
//        yoke.position = lastTouch
        #if targetEnvironment(simulator)
            yoke.position = lastTouch
            // simulator uses touches, while device uses accelerometer
        #else
            if let accelerometerData = motionManager.accelerometerData {
//                print("pitch: \(CGFloat(accelerometerData.acceleration.y)) roll: \(CGFloat(accelerometerData.acceleration.x))")
                tilt.position.x = size.width/2 + CGFloat(accelerometerData.acceleration.x) * size.width / 2
                    // changed from 3 to 2, makes less tilt yield full side yoke

                tilt.position.y = size.height/2 + CGFloat(accelerometerData.acceleration.y + 0.5) * size.height / 2
//                print("tilt.y: \(CGFloat(accelerometerData.acceleration.y)) \tyields position.y of: \(tilt.position.y)")
                // I want the tilt of -0.6 (full) to -0.75 to -0.9 (idle) to be the full range of
                //      200 to size.height/2
            }

        // This was trying to get tilt and roll from the gyro instead of the accelerometer.
        //        if let gyroData = motionManager.gyroData {
        //            let roll = gyroData.attitude.roll
        //            print(roll)
        //        }

            // min/max keeps yoke within limits of the screen
            yoke.position.x = limit((tilt.position.x + 2 * previousYoke.x ) / 3,        // this is weighting 2*previous vs tilt
                                    betweenMin: leftMargin + 60,
                                    andMax: leftMargin + playableWidth - 60)

    //            yoke.position.x = min(leftMargin + playableWidth - 30, max(leftMargin + 30, (tilt.position.x + 2 * previousYoke.x ) / 3))

            yoke.position.y = (tilt.position.y + 2 * previousYoke.y ) / 3

            previousYoke = yoke.position


        #endif

        // TODO - change all of these 100, 200 numbers to percentages of the screen height
        // throttle based on touch.y
//        racer.throttle = min(max((yoke.position.y - 200), 0), 400) / 400
//        racer.throttle = min(max(yoke.position.y / (size.height/2), 0.10), 1.0)
        racer.throttle = limit((yoke.position.y - 200) / (size.height/2 - 200),
                            betweenMin: 0.00, andMax: 1.0)
        newThrottle = 100 * limit((yoke.position.y - 200) / (size.height/2 - 200),
                            betweenMin: 0.10, andMax: 1.0)  // ranges 10 (at 200 pix) to 100 (at about 768)

        // the 200 is a pad at the bottom of the screen

        // move airspeed towards throttle
        throttleIndicator.position.y = size.height * 0.8 * racer.throttle + size.height * 0.1
//        print(racer.throttle)

//        print("touch.y: \(lastTouch.y) yields throttle of \(racer.throttle) and the airspeed is now \(airspeedPointsPerSec.y)")

        // TODO - add drag functionality from Python version
        let change : CGFloat = ((racer.throttle * 400) - airspeedPointsPerSec.y) / 20
        airspeedPointsPerSec.y += change
        if airspeedPointsPerSec.y < racer.minAirspeed {            // minimum speed limit
            airspeedPointsPerSec.y = racer.minAirspeed
        } else if airspeedPointsPerSec.y > racer.maxAirspeed {
            airspeedPointsPerSec.y = racer.maxAirspeed            // max speed limit
        }


        newDrag = pow(newAirspeed, 2) / 1000        // changed form 2000 to 1000 to increase decelleration rate

        // TODO - need to actually set a minPower value, so 0 throttle + draggy turns doesn't make plane drop off bottom of the screen.

//                print("Throttle: \(newThrottle)\tAirspeed: \(newAirspeed)\tDrag: \(newDrag)")  // ranges from about 0.1 to 1.0 (bottom of screen to middle)
        newAirspeed += (newThrottle + 10 - newDrag) / 50        // the + 10 is a see bit of power at 0% throttle



        // python version also has a line to add extra drag based on dx
//        newAirspeed -= abs(newVelocity.x) / 5


        newDistancePerUpate = 2.5 * newAirspeed * CGFloat(dt)

        // move racer
//        racer.position.x = yoke.position.x        // this is control mode 1: plane equal to yoke

//        racer.position.x += newVelocity.x      // this is mode 2: plane moves to yoke

        // mode 3! This is cool, but more difficult and a little less enjoyable to play.
//        if heading.position.x <= leftMargin + 30 {
//            heading.position.x = leftMargin + 30
//        } else if heading.position.x >= leftMargin + playableWidth - 30 {
//            heading.position.x = leftMargin + playableWidth - 30
//        }
//        heading.position.x += (yoke.position.x - size.width/2 ) / 5
//        racer.zRotation = (heading.position.x - size.width/2 ) / -400
//            // this is purely 'by eye' method, not mathematical at all.
//        racerShadow.zRotation = racer.zRotation
//
//        if racer.position.x <= leftMargin + racer.size.width {
//            racer.position.x = leftMargin + racer.size.width
//            heading.position.x += 20
//        } else if racer.position.x >= leftMargin + playableWidth - racer.size.width {
//            racer.position.x = leftMargin + playableWidth - racer.size.width
//            heading.position.x -= 20
//        }
//        racer.position.x += (heading.position.x - size.width/2) / 30

        /*
            We've got stick positin from the tilt/touch -> yoke

            If yoke.x < plane.x {
                dx -= abs(yoke.x - dx) / 7
                dx !< -newDistancePerUpdate + 1
            } else {
                dx += abs(yoke.x - dx) / 7
                dx !> newDistancePerUpdate - 1
            }
            x += dx
         */
        let stick = min(1.0, (yoke.position.x - racer.position.x) / (size.width/2))
       // stick is difference between yoke and plane, from -1 to 1
//        print(stick)
        newAirspeed -= 2 * abs(stick)
        // this is inspired by Python verion, where greater drag was increased by a 1.8 * abs(dx)
        // in this version, greater stick means greater drag

        let targetHeading = 2.2 * -stick        // increasing literal increases maximum turn angle
        newHeading = (newHeading + targetHeading) / 2
        // TODO - this just puts the heading as the average between current and target
        //      Should make it swing at a constant rate.
        //      Will likely need a change of heading value.

        // still sloppy...
        // still hitting on condition where dx comes out higher than vel
//        hdg: -0.7892237888890108     vel: 16.692588934000334      dx:16.82079923154579

        racer.zRotation = newHeading
        racerShadow.zRotation = racer.zRotation
        newVelocity.x = -sin(newHeading) * newDistancePerUpate
//        print("hdg: \(newHeading) \ttan: \(-tan(newHeading))\tvel: \(newDistancePerUpate) \t dx:\(newVelocity.x)")
        racer.position.x += newVelocity.x

        // could factor out " abs(stick - newVelocity.x) / 7 " below, and make sure it's not too extreme

//        if yoke.position.x < racer.position.x {         // stick to the left
//            newVelocity.x -= max(-10, abs(stick - newVelocity.x) / 7)
////            dx !< -newDistancePerUpdate + 1
//            if newVelocity.x < -newDistancePerUpate {
//                        newVelocity.x = newDistancePerUpate + 1
//                    }
//        } else {
//            newVelocity.x += min(10, abs(stick - newVelocity.x) / 7)
////            dx !> newDistancePerUpdate - 1
//            if newVelocity.x > newDistancePerUpate {
//                        newVelocity.x = -newDistancePerUpate - 1
//                    }
//        }
//        racer.position.x += newVelocity.x
//        print(newVelocity.x)

//        newVelocity.x = ( yoke.position.x - racer.position.x ) / 15
//        if newVelocity.x > newDistancePerUpate {
//            newVelocity.x = newDistancePerUpate - 1
//        } else if newVelocity.x < -newDistancePerUpate {
//            newVelocity.x = -newDistancePerUpate + 1
//        }
//        racer.position.x += newVelocity.x

        // SO HERE IT IS:
        /*
                Touch or Tilt -> defines Yoke
                Yoke -> Throttle -> Power
                Power - Drag -> delta.V
                Difference between Yoke and Position -> delta.x
                Delta.x and V -> Heading & delta.y

         */
        // newAirspeed = airspeedPointsPerSec.y
        // newHeading
        // newVelocity: CGPoint

//        print("Yoke: \(yoke.position.x)/\(yoke.position.y)")


        newVelocity.y = sqrt(newDistancePerUpate * newDistancePerUpate - newVelocity.x * newVelocity.x)
//        newHeading = atan2(newVelocity.x, newVelocity.y)
//        print("dh: \(newDistancePerUpate)\tdx: \(newVelocity.x)\tdy: \(newVelocity.y)\tHdg: \(newHeading)")

        // TODO - I think I need a currentHeading and a targetHeading, so we can ease currentHeading towards target and define a max deltaHeading

        // TODO - update motion to factor velocity and direction into seperate x and y values
        racer.position.y = ((newAirspeed - 100)/400 * size.height) - (newDistancePerUpate - newVelocity.y)
//        racer.position.y = racer.position.y + newVelocity.y - newDistancePerUpate
        // TODO - position.y needs to be based on something different.
        //      At the present, as you throttle down, the plane visually moves backwards compared to the background landscape.

        // TODO - At minimum speed/throttle, turns can make the plane drop off bottom of the screen.
        // Maybe we need to implement a cameraNode that tracks somehow tracks racer.position.y

        // ADJUST ALTITUDE:
            // this is just a crude, direct proportion means of setting altitude.
            // I would rather have it gain gradually, and lose altitude slowly on banks and throttle-downs
        racer.altitude = Int(newAirspeed / 20) + 4
//        print(racer.altitude)
            // could also make altitude effect zPosition, but that might be confusing.
            // ? but, might not? As pitching forward would indeed dive AND increase speed ??

        racerShadow.position.x = racer.position.x + 4 * CGFloat(racer.altitude)
        racerShadow.position.y = racer.position.y - 4 * CGFloat(racer.altitude)

        distanceThisUpdate = 3 * airspeedPointsPerSec.y * CGFloat(dt)

        // move landscape
        landscape.position.y -= newVelocity.y
//        print("delta y: \(newVelocity.y) pix")
        if landscape.position.y <= -landscape.size.height/2 {
            landscape.position.y -= landscape.position.y
//            print("background reset")
        }

        // TODO - need to create a singular delta-y variable, based on speed, used above and below and in the future, for the pylons

        // Cloud update. This used to be a class method in Python version.
        // could in theory make the height of each cloud vary.
        cloud.position.y = cloud.position.y - newVelocity.y
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
//                print(cloud.isDriftingRight)
            }
        }

        cloudShadow.position.x = cloud.position.x + 100
        cloudShadow.position.y = cloud.position.y - 100

        // update Pylons
        if pylonsAreRunning {
            leftJudge = leftPylon.update(by: newVelocity.y, otherPylon: rightPylon.position, racerAt: racer.position)
            rightJudge = rightPylon.update(by: newVelocity.y, otherPylon: leftPylon.position, racerAt: racer.position)

            if leftJudge == "GOOD" || rightJudge == "GOOD" {
                if !didPassFirstPylon {
                    didPassFirstPylon = true
                    startTime = currentTime
    //                print(startTime)
                }
                if !didPassLastPylon {
                    pylonsRemaining -= 1
                }
            } else if leftJudge == "MISS" || rightJudge == "MISS" {
                if !didPassFirstPylon {
                    didPassFirstPylon = true
                    startTime = currentTime
    //                print(startTime)
                }
                if !didPassLastPylon {
                    pylonsRemaining -= 1
                    pylonsMissed += 1
                }
            }
        }

        if pylonsRemaining <= 1 {
            if rightPylon.position.y > size.height / 5 {
                gameplayButton.position.y = rightPylon.position.y - rightPylon.frame.height / 2
            }
        }

        if !clockIsRunning && !runComplete && didPassFirstPylon {
            // start timing
            clockIsRunning = true
        }

        if clockIsRunning {
            elapsedRunTime = ( currentTime - startTime ) + Double((pylonsMissed * 5))        // (or whatever the penalty will be)
        }

        if !runComplete && pylonsRemaining <= 0 {
            runComplete = true
            didPassLastPylon = true
            clockIsRunning = false

            print("Game Over")
            print("Previous best time is \(bestTime)")

            if bestTime > 1 {
                print("Previous best exists")
                timeDifference = elapsedRunTime - bestTime
                if timeDifference >= 0 {
                    differenceLabel.text = String(format: "(+%.02f)", timeDifference)
                } else {
                    differenceLabel.text = String(format: "( %.02f)", timeDifference)
                }
                differenceLabel.isHidden = false

//                if elapsedRunTime < bestTime || bestTime == 0 {
//                    print("new best time set")
//                    print("should try to save it")
//                    bestTime = elapsedRunTime
//                    bestTimeLabel.text = String(format: "Best %.02f", bestTime)
//                }
            } else {
                print("no previous best time exists")
                // only run the first time, when there's no best time recorded
//                bestTime = elapsedRunTime
//                print(bestTime)
//                bestTimeLabel.text = String(format: "Best %.02f", bestTime)
            }
            
            if elapsedRunTime < bestTime || bestTime < 1 {
                print("new best time set at \(elapsedRunTime)")
                
                bestTime = elapsedRunTime
                bestTimeLabel.text = String(format: "Best %.02f", bestTime)
                
                print("should try to save it")
                BestTimesManager.sharedTimesManager.setBestTime(elapsedRunTime, forCourse: "One")
            }
                
            
        
        
            /*  List of Python END OF GAME actions:
                    √   clock_is_running = False
                    Fade out the engine sounds
                            plane.engine_sound_low.fadeout(8000)
                            plane.engine_sound_high.fadeout(400)
                    Should also reset and maybe land the plane?
                            stop listening to controls?
                            return to center
                            drop throttle to 0
                    if bestTime = 0 then there is no previous best and we can skip setting timeDifference
                            else
                                set timeDifference = elapsedRunTime - bestTime
                                reveal differenceLabel
                    # if this run was the best time...
                    if elapsedRunTime < bestTime or bestTime == 0:
                            bestTime = elapsedRunTime
                            # save_best_time(bestTime)
                            # new score class object
                            high_scores.scores_dictionary[str(difficulty_setting * 100 + starting_num_pylons)] = bestTime
                    */
            
            gameplayButtonLabel.fontColor = UIColor.white
            gameplayButtonLabel.text = "TAP HERE TO RESET"
//            gameplayButtonLabel.position = CGPoint(x: leftMargin + playableWidth / 2, y: size.height / 2 + 100)
            gameplayButtonLabel.isHidden = false
        }

        speedometerLabel.text = String("\(Int(newAirspeed)) mph")
        pylonCountLabel.text = String("\(pylonsRemaining) pylons to go")
        pylonMissLabel.text = String("\(pylonsMissed) missed")

        elapsedTimeLabel.text = String(format: "%.02f", elapsedRunTime)
        // TODO - there are still times when the digits wiggle
                // Arguably, we don't need to update the label every loop. We really only need to do it every 100/th of a second.



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
//        print(lastTouch)
    }
//
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
        lastTouch = pos
//        print(lastTouch)
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
    
    
    // Function to handle three-finger tap gesture
        @objc func handleThreeFingerTap(_ sender: UITapGestureRecognizer) {
            if sender.state == .ended {
                presentSettingsViewController()
            }
        }
    // Function to present settings view controller
        func presentSettingsViewController() {
//            let storyboard = UIStoryboard(name: "SettingsView", bundle: nil)
//            if let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
                // Present or push the settings view controller
//                present(settingsViewController, animated: true, completion: nil)
//                settingsViewController.sampleSettingValue = 3
            print("Setting Value set to \(settingsViewController.sampleSettingValue) by GameScene")
                settingsViewController.modalPresentationStyle = .overCurrentContext // Present modally over the current context
                view?.window?.rootViewController?.present(settingsViewController, animated: true, completion: nil)
//            }
//            if let settingsViewController = SettingsViewController() // Instantiate your settings view controller
            
        }
    // Function to dismiss settings view controller
//        func dismissSettingsViewController() {
//            print("Settings Dismissed")
//            sampleSetting = settingsViewController.sampleSettingValue
//            print("GameScene.sampleSetting set to \(sampleSetting) by dismissSettingsViewController")
//            view?.window?.rootViewController?.dismiss(animated: true, completion: nil)
//        }
    
//    func simpleGameSceneFunc() {
//        print("Simple function called")
//        print(" settingsViewController.sampleSettingValue is \(settingsViewController.sampleSettingValue)")
//    }
    
    func resetGame() {
        print("Game Reset!")
        pylonsAreRunning = false
        clockIsRunning = false

        setupGame()

    }

    func setupGame() {
        leftJudge = ""
        rightJudge = ""
        pylonsRemaining = 10
        pylonsMissed = 0

        didPassFirstPylon = false
        leftPylon.position = CGPoint(x: leftMargin + playableWidth * 0.25, y: size.height + leftPylon.size.height)
        leftPylon.number = pylonsRemaining
        leftPylon.isPassed = false
        leftPylon.texture = SKTexture(imageNamed: "pylon_L")

        didPassLastPylon = false
        rightPylon.position = CGPoint(x: leftMargin + playableWidth * 0.75, y: leftPylon.position.y + size.height/2 + rightPylon.size.height)
        rightPylon.number = pylonsRemaining - 1
        rightPylon.isPassed = false
        rightPylon.texture = SKTexture(imageNamed: "pylon_R")

//        gameplayButtonLabel.position = CGPoint(x: leftMargin + playableWidth / 2, y: size.height / 2)
        gameplayButtonLabel.fontColor = UIColor.green
        gameplayButtonLabel.horizontalAlignmentMode = .left
        gameplayButtonLabel.text = "TAP HERE TO BEGIN"
        isInitiallyPaused = true
        runComplete = false
        elapsedRunTime = 0

        differenceLabel.isHidden = true
    }
}
