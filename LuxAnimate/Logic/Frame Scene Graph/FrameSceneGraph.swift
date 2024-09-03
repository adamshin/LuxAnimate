//
//  FrameSceneGraph.swift
//

import Foundation

struct FrameSceneGraph {
    
    struct Layer {
        var contentSize: Size
        var transform: Matrix3
        var alpha: Double
        
        var content: LayerContent
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

extension FrameSceneGraph {
    
    func generate(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) -> FrameSceneGraph {
        
        // TODO
        fatalError()
    }
    
}
