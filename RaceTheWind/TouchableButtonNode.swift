//
//  MyTouchableButtonNode.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 12/16/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class TouchableButtonNode: SKShapeNode {
    var wasTouched: Bool = false

        override var isUserInteractionEnabled: Bool {
            set {
                // ignore
            }
            get {
                return true
            }
        }

        // For macOS replace this method with `mouseDown(with:)`
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            // User has touched this node
    //        print("Touched")
            wasTouched = true
        }
}

//  https://developer.apple.com/documentation/spritekit/sknode/controlling_user_interaction_on_nodes
//
