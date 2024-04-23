//
//  CGGeometry.swift
//

import Foundation

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height)
    }
    
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
}

extension CGPoint {
    
    func distance(to p: CGPoint) -> CGFloat {
        hypot(p.x - x, p.y - y)
    }
    
}
