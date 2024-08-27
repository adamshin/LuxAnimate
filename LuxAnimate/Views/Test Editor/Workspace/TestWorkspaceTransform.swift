//
//  TestWorkspaceTransform.swift
//

import Foundation

struct TestWorkspaceTransform {
    var translation: Vector2
    var rotation: Scalar
    var scale: Scalar
}

extension TestWorkspaceTransform {
    
    static let identity = TestWorkspaceTransform(
        translation: .zero,
        rotation: 0,
        scale: 1)
    
    mutating func applyTranslation(
        _ dTranslation: Vector2
    ) {
        translation += dTranslation
    }
    
    mutating func applyRotation(
        _ dRotation: Scalar,
        anchor: Vector2
    ) {
        applyTranslation(-anchor)
        
        rotation = wrap(rotation + dRotation, to: .twoPi)
        translation = translation.rotated(by: dRotation)
        
        applyTranslation(anchor)
    }
    
    mutating func applyScale(
        _ dScale: Scalar,
        minScale: Scalar,
        maxScale: Scalar,
        anchor: Vector2
    ) {
        let newScale = clamp(
            scale * dScale,
            min: minScale,
            max: maxScale)
        
        let scaleFactor = max(0, newScale / scale)
        
        applyTranslation(-anchor)
        
        scale *= scaleFactor
        translation *= scaleFactor
        
        applyTranslation(anchor)
    }
    
    mutating func snapTranslationToKeepRectContainingOrigin(
        x: Scalar, y: Scalar,
        width: Scalar, height: Scalar
    ) {
        let matrix = matrix()
        let matrixInverse = matrix.inverse()
        
        let targetPointInRectSpace = matrixInverse * Vector.zero
        
        let closestRectPointInRectSpace = Vector(
            x: clamp(targetPointInRectSpace.x, min: x, max: x + width),
            y: clamp(targetPointInRectSpace.y, min: y, max: y + height))
        
        let closestRectPointInViewSpace = matrix * closestRectPointInRectSpace
        
        applyTranslation(-closestRectPointInViewSpace)
    }
    
    mutating func snapRotation(
        threshold: Scalar,
        anchor: Vector
    ) {
        let snapAngles: [Scalar] = (0...4)
            .map { Scalar($0) / 4 * .twoPi }
        
        for snapAngle in snapAngles {
            let distance = snapAngle - rotation
            if abs(distance) < threshold {
                applyRotation(distance, anchor: anchor)
                break
            }
        }
    }
    
    mutating func snapScale(
        minScale: Scalar,
        maxScale: Scalar,
        anchor: Vector
    ) {
        applyScale(1,
            minScale: minScale,
            maxScale: maxScale,
            anchor: anchor)
    }
    
    func matrix() -> Matrix3 {
        let t1 = Matrix3(scale: Vector2(scale, scale))
        let t2 = Matrix3(rotation: rotation)
        let t3 = Matrix3(translation: translation)
        
        return t3 * t2 * t1
    }
    
}
