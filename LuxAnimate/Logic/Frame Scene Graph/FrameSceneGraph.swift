//
//  FrameSceneGraph.swift
//

import Foundation

struct FrameSceneGraph {
    
    struct Layer {
        var content: LayerContent
        var contentSize: Size
        var transform: Matrix3
        var alpha: Double
    }
    
    enum LayerContent {
        case drawing(DrawingLayerContent)
    }
    
    struct DrawingLayerContent {
        var drawing: Scene.Drawing
    }
    
    var contentSize: Size
    var backgroundColor: Color
    
    var layers: [Layer]
    
}
