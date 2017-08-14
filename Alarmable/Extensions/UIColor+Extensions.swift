//
//  UIColor+Extensions.swift
//  Alarmable
//
//  Created by Haven Barnes on 6/17/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(_ hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hexString).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hexString.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /**
     Converts a UIColor object to a string with it's hex code representation
     
     
     - parameter color: The input UIColor object representing the desired color
     
     - returns:   String The representation of the color in hexadecimal
     */
    func hex() -> String {
        let hexString = String(format: "%02X%02X%02X",
                               Int((self.cgColor.components?[0])! * 255.0),
                               Int((self.cgColor.components?[1])! * 255.0),
                               Int((self.cgColor.components?[2])! * 255.0))
        return hexString
    }
    
    
    var red: CGFloat{ return CIColor(color: self).red }
    var green: CGFloat{ return CIColor(color: self).green }
    var blue: CGFloat{ return CIColor(color: self).blue }
    var alpha: CGFloat{ return CIColor(color: self).alpha }
    
    /**
     Adjusts the hue of the UIColor by the desired value and returns a new UIColor
     
     - Parameter degree: Amount (in degrees) to adjust hue.
     
     - Returns: Color with adjusted hue.
     */
    func adjustHue(by degree: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0, sat: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        var adjustedHue = degree / 360
        
        self.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha)
        
        adjustedHue = hue + adjustedHue
        
        if !((0.0..<1.0).contains(adjustedHue)) {
            adjustedHue = abs(1 - abs(adjustedHue))
        }
        
        return UIColor(hue: adjustedHue, saturation: sat, brightness: brightness, alpha: alpha)
    }
    
    /**
     Creates a three color gradient from a single color.
     
     - Parameter bounds: The bounds of the gradent.
     
     - Returns: CAGradientLayer with three colors.
     */
    func gradientColors() -> [CGColor] {
        
        let color1 = self.adjustHue(by: -20)
        let color2 = self
        let color3 = self.adjustHue(by: 20)
        return [color1.cgColor, color2.cgColor, color3.cgColor]
    }

}
