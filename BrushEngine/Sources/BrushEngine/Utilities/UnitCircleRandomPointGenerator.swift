
import Foundation
import Geometry

struct UnitCircleRandomPointGenerator {
    
    private let polarConverter = PolarApproximateConverter()
    
    private let angleRange: Range<Double> = 0 ..< .twoPi
    private let distanceRange: Range<Double> = 0 ..< 1
    
    func point<T>(
        using generator: inout T
    ) -> Vector2 where T: RandomNumberGenerator {
        
        let angle = Double.random(
            in: angleRange, using: &generator)
        
        let distance = Double.random(
            in: distanceRange, using: &generator)
        
        return polarConverter.point(
            angle: angle, distance: distance)
    }
    
}
