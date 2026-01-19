//
//  FrameSceneGraph.swift
//

import Foundation
import Geometry
import Color

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
        var drawing: Project.Drawing
    }
    
    var contentSize: Size
    var backgroundColor: Color
    
    var layers: [Layer]
    
}
