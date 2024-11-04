
import Foundation
import Geometry

struct PolarApproximateConverter {
    
    private let vertexCount: Int
    private let vertices: [Vector2]
    
    init(vertexCount: Int = 32) {
        self.vertexCount = vertexCount
        
        vertices = (0 ..< vertexCount).map { i in
            let t = Double(i) / Double(vertexCount)
            let a = t * .twoPi
            return Vector(cos(a), sin(a))
        }
    }
    
    func point(
        angle: Double,
        distance: Double
    ) -> Vector2 {
        let normalizedAngle = angle
            .truncatingRemainder(dividingBy: .twoPi)
        
        let angleRatio = normalizedAngle / .twoPi
        
        let exactIndex = angleRatio * Double(vertexCount)
        let index1 = Int(exactIndex)
        let index2 = (index1 + 1) % vertexCount
        
        let fract = exactIndex
            .truncatingRemainder(dividingBy: 1)
        
        let v1 = vertices[index1]
        let v2 = vertices[index2]
        
        let v = v1 + (v2 - v1) * fract
        
        return v * distance
    }
    
}
