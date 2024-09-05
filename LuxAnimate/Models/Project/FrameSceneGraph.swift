//
//  FrameSceneGraph.swift
//

import Foundation

struct FrameSceneGraph: Codable {
    
    struct Layer: Codable {
        var content: LayerContent
        var contentSize: Size
        var transform: Matrix3
        var alpha: Double
    }
    
    enum LayerContent: Codable {
        case drawing(DrawingLayerContent)
    }
    
    struct DrawingLayerContent: Codable {
        var drawing: Scene.Drawing
    }
    
    var contentSize: Size
    var backgroundColor: Color
    
    var layers: [Layer]
    
}
