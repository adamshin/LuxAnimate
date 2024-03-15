//
//  CGPoint+Extensions.swift
//

import Foundation

extension CGPoint {
    
    func distance(to p: CGPoint) -> CGFloat {
        hypot(p.x - x, p.y - y)
    }
    
}
