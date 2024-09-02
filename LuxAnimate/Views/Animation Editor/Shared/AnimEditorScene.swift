//
//  AnimEditorScene.swift
//

import Foundation
import Metal

struct AnimEditorScene {
    
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
