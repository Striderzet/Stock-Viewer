//
//  HapticAction.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/9/21.
//

import Foundation
import SwiftUI

//MARK: Small method for haptic feedback when button gets touched.

///Adjustable haptic feedback for buttons
func setHaptic(strength: UIImpactFeedbackGenerator.FeedbackStyle) {
    let impact = UIImpactFeedbackGenerator(style: strength)
        impact.impactOccurred()
}
