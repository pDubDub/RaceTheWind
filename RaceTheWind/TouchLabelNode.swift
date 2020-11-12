//
//  TouchLabelNode.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 11/2/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.

//  https://developer.apple.com/documentation/spritekit/sknode/controlling_user_interaction_on_nodes
//

import Foundation
import SpriteKit

class TouchLabelNode: SKLabelNode {

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
