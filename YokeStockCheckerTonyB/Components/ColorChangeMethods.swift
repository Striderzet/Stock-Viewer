//
//  ColorChangeMethods.swift
//  YokeStockCheckerTonyB
//
//  Created by Tony Buckner on 3/9/21.
//

import Foundation
import SwiftUI
import UIKit

//MARK: These methods will return colors from percentage chnages.

//set buttons on and off visually
func buttonOnColor(isON: Bool) -> Color {
    return isON ? Color.green : Color.clear
}

//set text color according to on and off
func textOnColor(isON: Bool) -> Color {
    return isON ? Color.white : Color.green
}

//this will be changed live
func percentageChangeColor(_ percentageChange: String) -> Color {
    var newPerChange = percentageChange
    newPerChange.removeLast()
    if let perChange = Double(newPerChange) {
        return perChange < 0 ? Color.red : Color.green
    } else {
        return  Color.clear
    }
}

//MARK: - BONUS: A method that truncates the crazy float values to a normal dollar string

///Convert CGFloat to dollar string
func floatConvertToDollar(_ number: CGFloat) -> String {

    var newStr = "$\(number)"
    
    if let startDotIndex = newStr.firstIndex(of: ".") {
        
        //this is for the float string that came back too short for truncation
        if newStr.lastIndex(of: ".") != newStr.index(newStr.endIndex, offsetBy: -2) {
            newStr.removeSubrange(newStr.index(startDotIndex, offsetBy: 3)..<newStr.endIndex)
        } else {
            //add this char for persistence
            newStr += "0"
        }
    }
    return newStr
}
