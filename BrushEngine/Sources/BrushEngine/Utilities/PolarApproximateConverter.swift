
import Foundation
import Geometry

struct PolarApproximateConverter {
    
    private let vertexCount: Int
    private let vertices: [Vector2]
    private let indexMultiplier: Double
    
    init(vertexCount: Int = 32) {
        precondition(
            vertexCount.nonzeroBitCount == 1,
            "vertexCount must be power of 2")
        
        self.vertexCount = vertexCount
        self.indexMultiplier = Double(vertexCount) / .twoPi
        
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
        let rawIndex = angle * indexMultiplier
        let intIndex = Int(rawIndex)
        let fract = rawIndex - Double(intIndex)
        
        let index1 = intIndex & (vertexCount - 1)
        let index2 = (index1 + 1) & (vertexCount - 1)
        
        let v1 = vertices[index1]
        let v2 = vertices[index2]
        
        let v = v1 + (v2 - v1) * fract
        return v * distance
    }
    
}
