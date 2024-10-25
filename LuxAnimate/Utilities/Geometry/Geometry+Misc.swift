//
//  Geometry+Misc.swift
//

import Foundation

extension Vector2 {
    
    init(_ p: CGPoint) {
        self.init(x: p.x, y: p.y)
    }
    
    var description: String {
        String(format: "(x: %0.3f, y: %0.3f)", x, y)
    }
    
}

extension CGPoint {
    
    init(_ v: Vector2) {
        self.init(x: v.x, y: v.y)
    }
    
}

extension CGSize {
    
    init(_ s: Size2) {
        self.init(width: s.width, height: s.height)
    }
    
}

extension Size2 {
    
    init(_ s: CGSize) {
        self.init(width: s.width, height: s.height)
    }
    
}

extension Matrix3 {
    
    var cgAffineTransform: CGAffineTransform {
        CGAffineTransform(
            a: m11, b: m21,
            c: m12, d: m22,
            tx: m13, ty: m23)
    }
}
