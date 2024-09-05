//
//  EditorWorkspaceSceneGraph.swift
//

import Foundation
import Metal

struct EditorWorkspaceSceneGraph {
    
    struct Layer {
        var content: LayerContent
        var contentSize: Size
        var transform: Matrix3
        var alpha: Double
    }
    
    enum LayerContent {
        case image(ImageLayerContent)
        case rect(RectLayerContent)
    }
    
    struct ImageLayerContent {
        var texture: MTLTexture?
        var colorMode: ColorMode
        var color: Color
    }
    
    struct RectLayerContent {
        var color: Color
    }
    
    var contentSize: Size
    var layers: [Layer]
    
    // TODO: Overlay content, drawn in screen space?
    
}
