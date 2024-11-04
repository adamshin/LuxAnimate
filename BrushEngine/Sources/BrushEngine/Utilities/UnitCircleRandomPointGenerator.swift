
import Foundation
import Geometry

struct UnitCircleRandomPointGenerator {
    
    private let polarConverter = PolarApproximateConverter()
    
    func point<T>(
        using generator: inout T
    ) -> Vector2 where T: RandomNumberGenerator {
        
        let angle = Double.random(
            in: 0 ..< .twoPi,
            using: &generator)
        
        let distance = Double.random(
            in: 0 ..< 1,
            using: &generator)
        
        return polarConverter.point(
            angle: angle,
            distance: distance)
    }
    
}
