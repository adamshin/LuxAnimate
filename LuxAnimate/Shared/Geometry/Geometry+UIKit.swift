//
//  Geometry+UIKit.swift
//

import Foundation

extension Vector2 {
    init(_ p: CGPoint) { self.init(x: p.x, y: p.y) }
}

extension CGPoint {
    init(_ v: Vector2) { self.init(x: v.x, y: v.y) }
}
