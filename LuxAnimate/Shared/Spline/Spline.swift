//
//  Spline.swift
//

import Foundation

// MARK: - CubicSpline

struct CubicSpline {
    
    var c0, c1, c2, c3: Scalar
    
    func value(at t: Scalar) -> Scalar {
        let t1 = t
        let t2 = t*t
        let t3 = t2*t
        
        return c0 + c1*t1 + c2*t2 + c3*t3
    }
    
}

extension CubicSpline {
    
    init(p0: Scalar, p1: Scalar, m0: Scalar, m1: Scalar) {
        c0 = p0
        c1 = m0
        c2 = -3*p0 + 3*p1 - 2*m0 - m1
        c3 = 2*p0 - 2*p1 + m0 + m1
    }
    
    static func catmullRom(
        p0: Scalar, p1: Scalar, p2: Scalar, p3: Scalar
    ) -> CubicSpline {
        
        let m1 = 0.5 * (p2 - p0)
        let m2 = 0.5 * (p3 - p1)
        
        return CubicSpline(
            p0: p1, p1: p2,
            m0: m1, m1: m2)
    }
    
    static func linear(
        p0: Scalar, p1: Scalar, p2: Scalar, p3: Scalar
    ) -> CubicSpline {
        
        return CubicSpline(
            p0: p1, p1: p2,
            m0: 0, m1: 0)
    }
    
}

// MARK: - CubicSpline2

struct CubicSpline2 {
    
    var splineX: CubicSpline
    var splineY: CubicSpline
    
    func value(at t: Scalar) -> Vector2 {
        Vector2(
            splineX.value(at: t),
            splineY.value(at: t))
    }
    
}

extension CubicSpline2 {
    
    static func catmullRom(
        p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2
    ) -> CubicSpline2 {
        
        CubicSpline2(
            splineX: .catmullRom(
                p0: p0.x, p1: p1.x, p2: p2.x, p3: p3.x),
            splineY: .catmullRom(
                p0: p0.y, p1: p1.y, p2: p2.y, p3: p3.y))
    }
    
    static func linear(
        p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2
    ) -> CubicSpline2 {
        
        CubicSpline2(
            splineX: .linear(
                p0: p0.x, p1: p1.x, p2: p2.x, p3: p3.x),
            splineY: .linear(
                p0: p0.y, p1: p1.y, p2: p2.y, p3: p3.y))
    }
    
}
