
// TODO: Extract this into a package?

import Foundation
import UIKit
import Metal

public struct Color: Sendable, Codable {
    public var r, g, b, a: UInt8
}

public extension Color {
    
    static let clear = Color(0, 0, 0, 0)
    
    static let black = Color(hex: "000000")
    static let white = Color(hex: "FFFFFF")
    
    static let red = Color(hex: "FF0000")
    static let green = Color(hex: "00FF00")
    static let blue = Color(hex: "0000FF")
    
    static let brushBlack = Color(hex: "404448")
    static let brushRed = Color(hex: "FA7070")
    static let brushGreen = Color(hex: "88AB8E")
    static let brushBlue = Color(hex: "61A3BA")
    
    static let debugRed = Color(hex: "FF3B30")
    static let debugOrange = Color(hex: "FF6B30")
    static let debugGreen = Color(hex: "00FF80")
    
    static let halfGray = Color(hex: "808080")
    
}

public extension Color {
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.init(r: r, g: g, b: b, a: a)
    }
    
    init(_ color: UIColor) {
        let srgbColor = color.cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .absoluteColorimetric,
            options: nil)
        
        guard let srgbColor,
            let components = srgbColor.components,
            srgbColor.numberOfComponents == 4
        else {
            self = .clear
            return
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components[3]
        
        self.init(
            UInt8(r * 255),
            UInt8(g * 255),
            UInt8(b * 255),
            UInt8(a * 255))
    }
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        
        var rgb: UInt64 = 0
        guard scanner.scanHexInt64(&rgb) else {
            self = .clear
            return
        }
        
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = (rgb >> 0) & 0xFF
        
        self.init(UInt8(r), UInt8(g), UInt8(b), 255)
    }
    
    func withAlpha(_ alpha: Double) -> Color {
        var c = self
        let a = max(Double(c.a) * alpha, 0)
        c.a = UInt8(a)
        return c
    }
    
//    var cgColor: CGColor {
//        CGColor(
//            srgbRed: CGFloat(r) / 255,
//            green: CGFloat(g) / 255,
//            blue: CGFloat(b) / 255,
//            alpha: CGFloat(a) / 255)
//    }
    
//    var uiColor: UIColor {
//        UIColor(cgColor: cgColor)
//    }
    
    var mtlClearColor: MTLClearColor {
        MTLClearColorMake(
            Double(r) / 255,
            Double(g) / 255,
            Double(b) / 255,
            Double(a) / 255)
    }
    
}
