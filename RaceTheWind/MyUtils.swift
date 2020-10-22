//
//  MyUtils.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 10/7/20.
//  Copyright © 2020 Patrick Wheeler. All rights reserved.
//

import Foundation
import CoreGraphics

func limiter(_ input: CGFloat, toPlusOrMinus limit: CGFloat) -> CGFloat {
    return min(limit, max(-limit, input))
}

func limit(_ input: CGFloat, betweenMin lower: CGFloat, andMax upper: CGFloat) -> CGFloat {
    return min(upper, max(lower, input))
}
