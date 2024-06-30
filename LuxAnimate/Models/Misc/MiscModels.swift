//
//  MiscModels.swift
//

import Foundation
import Metal

struct Color: Codable {
    var r, g, b, a: UInt8
}

struct PixelSize: Codable {
    var width, height: Int
}

// MARK: - Extensions

extension Color {
    
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
    
}

extension Color {
    
    init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
        self.init(r: r, g: g, b: b, a: a)
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
        c.a = UInt8(Double(c.a) * alpha)
        return c
    }
    
    var mtlClearColor: MTLClearColor {
        MTLClearColorMake(
            Double(r) / 255,
            Double(g) / 255,
            Double(b) / 255,
            Double(a) / 255)
    }
    
}

extension PixelSize {
    
    init(
        filling containerSize: PixelSize,
        aspectRatio: Double
    ) {
        let containerAspectRatio =
            Double(containerSize.width) /
            Double(containerSize.height)
        
        if aspectRatio > containerAspectRatio {
            self = PixelSize(
                width: Int(Double(containerSize.height) * aspectRatio),
                height: containerSize.height)
        } else {
            self = PixelSize(
                width: containerSize.width,
                height: Int(Double(containerSize.width) / aspectRatio))
        }
    }

    init(
        fitting containerSize: PixelSize,
        aspectRatio: Double
    ) {
        let containerAspectRatio =
            Double(containerSize.width) /
            Double(containerSize.height)
        
        if aspectRatio > containerAspectRatio {
            self = PixelSize(
                width: containerSize.width,
                height: Int(Double(containerSize.width) / aspectRatio))
        } else {
            self = PixelSize(
                width: Int(Double(containerSize.height) * aspectRatio),
                height: containerSize.height)
        }
    }
    
}
