//
//  PixelSize.swift
//

import Foundation

struct PixelSize: Codable {
    var width, height: Int
}

extension PixelSize {
    
    static let zero = PixelSize(0, 0)
    
    init(_ width: Int, _ height: Int) {
        self.init(width: width, height: height)
    }
    
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

extension Size2 {
    
    init(_ s: PixelSize) {
        self.init(
            width: Double(s.width),
            height: Double(s.height))
    }
    
}
