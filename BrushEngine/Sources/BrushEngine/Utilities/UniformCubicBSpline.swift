//
//  UniformCubicBSpline.swift
//

import Geometry

struct UniformCubicBSpline {
    
    static func basisValues(
        t: Double
    ) -> (Double, Double, Double, Double) {
        let t2 = t*t
        let t3 = t2*t
        
        let b0 = (-t3 + 3*t2 - 3*t + 1) / 6
        let b1 = (3*t3 - 6*t2 + 4) / 6
        let b2 = (-3*t3 + 3*t2 + 3*t + 1) / 6
        let b3 = t3 / 6
        
        return (b0, b1, b2, b3)
    }
    
}
