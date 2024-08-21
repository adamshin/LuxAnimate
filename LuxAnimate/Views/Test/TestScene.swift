//
//  TestScene.swift
//

import Foundation

struct TestScene {
    
    struct Layer {
        var transform: Matrix3
        var contentSize: Size
        var alpha: Double
        var content: LayerContent
    }
    
    enum LayerContent {
        case rect(RectLayerContent)
    }
    
    struct RectLayerContent {
        var color: Color
    }
    
    var layers: [Layer]
    
}

extension TestScene {
    
    static func generate(
        timestamp: Double
    ) -> TestScene {
        
        TestScene(
            layers: [
                TestScene.Layer(
                    transform: .identity,
                    contentSize: Size(1000, 1000),
                    alpha: 1,
                    content: .rect(
                        .init(color: .white))),
                
                TestScene.Layer(
                    transform: Matrix3(translation: Vector(-400, -200)),
                    contentSize: Size(100, 500),
                    alpha: 1,
                    content: .rect(
                        .init(color: .brushGreen))),
                
                TestScene.Layer(
                    transform: Matrix3(rotation: timestamp),
                    contentSize: Size(300, 300),
                    alpha: 0.8,
                    content: .rect(
                        .init(color: .brushRed))),
                
                TestScene.Layer(
                    transform: Matrix3(translation: Vector(100, 100)),
                    contentSize: Size(300, 300),
                    alpha: 1,
                    content: .rect(
                        .init(color: .brushBlue))),
            ])
    }
    
}
