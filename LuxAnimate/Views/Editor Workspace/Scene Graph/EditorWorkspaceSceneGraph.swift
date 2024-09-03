//
//  EditorWorkspaceSceneGraph.swift
//

import Foundation
import Metal

struct EditorWorkspaceSceneGraph {
    
    struct Layer {
        var contentSize: Size
        var transform: Matrix3
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
    
    // TODO: Overlay content, drawn in screen space?
    
}
