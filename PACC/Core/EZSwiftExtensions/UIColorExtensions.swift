//
//  UIColorExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

//#if os(iOS) || os(tvOS)
//
//import UIKit
//
//extension UIColor {
//    /// EZSE: init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
//    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
//        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
//    }
//
//    /// EZSE: init method with hex string and alpha(default: 1)
//    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
//
//        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
//        formatted = formatted.replacingOccurrences(of: "#", with: "")
//        if let hex = Int(formatted, radix: 16) {
//          let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
//          let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
//          let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
//          self.init(red: red, green: green, blue: blue, alpha: alpha)        } else {
//            return nil
//        }
//    }
//
//
//
//    public convenience init?(hexAlpha: String) {
//
//        let r, g, b, a: CGFloat
//
//        var formatted = hexAlpha.replacingOccurrences(of: "0x", with: "")
//        formatted = formatted.replacingOccurrences(of: "#", with: "")
//
//        if formatted.count == 8 {
//            let scanner = Scanner(string: formatted)
//            var hexNumber: UInt64 = 0
//
//            if scanner.scanHexInt64(&hexNumber) {
//                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
//                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
//                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
//                a = CGFloat(hexNumber & 0x000000ff) / 255
//
//                self.init(red: r, green: g, blue: b, alpha: a)
//                return
//            }
//            else{
//
//                return nil
//            }
//        }
//        else{
//
//            if let hex = Int(formatted, radix: 16) {
//                let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
//                let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
//                let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
//                self.init(red: red, green: green, blue: blue, alpha: 1)
//
//            }
//            else {
//                return nil
//            }
//        }
//    }
//
//
//
//    /// EZSE: init method from Gray value and alpha(default:1)
//    public convenience init(gray: CGFloat, alpha: CGFloat = 1) {
//        self.init(red: gray/255, green: gray/255, blue: gray/255, alpha: alpha)
//    }
//
//    /// EZSE: Red component of UIColor (get-only)
//    public var redComponent: Int {
//        var r: CGFloat = 0
//        getRed(&r, green: nil, blue: nil, alpha: nil)
//        return Int(r * 255)
//    }
//
//    /// EZSE: Green component of UIColor (get-only)
//    public var greenComponent: Int {
//        var g: CGFloat = 0
//        getRed(nil, green: &g, blue: nil, alpha: nil)
//        return Int(g * 255)
//    }
//
//    /// EZSE: blue component of UIColor (get-only)
//    public var blueComponent: Int {
//        var b: CGFloat = 0
//        getRed(nil, green: nil, blue: &b, alpha: nil)
//        return Int(b * 255)
//    }
//
//    /// EZSE: Alpha of UIColor (get-only)
//    public var alpha: CGFloat {
//        var a: CGFloat = 0
//        getRed(nil, green: nil, blue: nil, alpha: &a)
//        return a
//    }
//
//    /// EZSE: Returns random UIColor with random alpha(default: false)
//    public static func random(randomAlpha: Bool = false) -> UIColor {
//        let randomRed = CGFloat.random()
//        let randomGreen = CGFloat.random()
//        let randomBlue = CGFloat.random()
//        let alpha = randomAlpha ? CGFloat.random() : 1.0
//        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
//    }
//
//}
//
//#endif


import UIKit

public extension UIColor
{
    convenience init(hexValue: Int, alpha: CGFloat = 1.0)
    {
        let red     = (hexValue >> 16) & 0xff
        let green   = (hexValue >> 8) & 0xff
        let blue    = hexValue & 0xff
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(hexString: String)
    {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        
        switch hex.count
        {
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
    
    convenience init(rgbaString: String)
    {
        let rgba    = rgbaString.replacingOccurrences(of: "rgba(", with: "", options: .literal, range:nil).replacingOccurrences(of: ")", with: "", options: .literal, range:nil)
        let result  = rgba.split(separator: ",")
        
        let r       = CGFloat((result[0] as NSString).floatValue)
        let g       = CGFloat((result[1] as NSString).floatValue)
        let b       = CGFloat((result[2] as NSString).floatValue)
        //        let a       = CGFloat((result[3] as NSString).floatValue)
        
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
    
    func as1ptImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize.init(width: 1.0, height: 1.0))
        var image: UIImage? = nil
        if let ctx = UIGraphicsGetCurrentContext()
        {
            self.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Returns random generated color.
    static var random: UIColor
    {
        srandom(arc4random())
        var red: Double = 0
        
        while (red < 0.1 || red > 0.84)
        {
            red = drand48()
        }
        
        var green: Double = 0
        while (green < 0.1 || green > 0.84)
        {
            green = drand48()
        }
        
        var blue: Double = 0
        while (blue < 0.1 || blue > 0.84)
        {
            blue = drand48()
        }
        
        return .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
    static func colorHash(name: String?) -> UIColor
    {
        guard let name = name else
        {
            return .red
        }
        
        var nameValue = 0
        for character in name
        {
            let characterString = String(character)
            let scalars         = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }
        
        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        return .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }
}

