//
//  TestScene.swift
//

import Foundation
import Metal

struct TestScene {
    
    struct Layer {
        var transform: Matrix3
        var contentSize: Size
        var alpha: Double
        var content: LayerContent
    }
    
    enum LayerContent {
        case drawing(DrawingLayerContent)
        case rect(RectLayerContent)
    }
    
    struct DrawingLayerContent {
        var texture: MTLTexture
    }
    
    struct RectLayerContent {
        var color: Color
    }
    
    var layers: [Layer]
    
}
