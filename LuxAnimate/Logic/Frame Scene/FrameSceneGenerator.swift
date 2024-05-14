//
//  FrameSceneGenerator.swift
//

import Foundation

struct FrameSceneGenerator {
    
    static func generate(
        projectManifest: Project.Manifest,
        frameIndex: Int
    ) -> FrameScene {
        
        var layers: [FrameSceneLayer] = []
        
        let drawings = projectManifest
            .content.animationLayer.drawings
        
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
