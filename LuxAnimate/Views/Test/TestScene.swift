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
