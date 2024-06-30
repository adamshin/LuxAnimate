//
//  FrameScene.swift
//

import Foundation

// Make this part of EditorFrameEditorScene?
struct FrameScene {
    
    var backgroundColor: Color
    var layers: [FrameSceneLayer]
    
}

enum FrameSceneLayer {
    case drawing(FrameSceneDrawingLayer)
}

struct FrameSceneDrawingLayer {
    var drawing: Project.Drawing
}

// MARK: - Generation

extension FrameScene {
    
    static func generate(
        projectManifest: Project.Manifest,
        frameIndex: Int
    ) -> FrameScene {
        
        var layers: [FrameSceneLayer] = []
        
        let drawings = projectManifest
            .content.scene.animationLayer.drawings
        
        if let drawing = ProjectHelper.drawingForFrame(
            drawings: drawings,
            frameIndex: frameIndex)
        {
            let layer = FrameSceneLayer.drawing(
                FrameSceneDrawingLayer(
                    drawing: drawing))
            
            layers.append(layer)
        }
        
        return FrameScene(
            backgroundColor: .white,
            layers: layers)
    }
    
}
