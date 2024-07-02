//
//  EditorModelGenerator.swift
//

import Foundation

struct EditorModelGenerator {
    
    func generate(
        from projectManifest: Project.Manifest
    ) -> EditorModel {
        
        let scene = projectManifest.content.scenes.first!
        
        let animationLayerContent = switch scene.layers.first!.content {
        case let .animation(animationLayerContent):
            animationLayerContent
        }
        
        let framesPerSecond = projectManifest.metadata.framesPerSecond
        
        let emptyFrame = EditorModel.Frame(
            hasDrawing: false,
            thumbnailURL: nil)
        
        var frames = Array(
            repeating: emptyFrame,
            count: scene.frameCount)
        
        // Put drawings on frames
        let drawings = animationLayerContent.drawings
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let thumbnailURL = FileHelper.shared.projectAssetURL(
                projectID: projectManifest.id,
                assetID: drawing.assetIDs.small)
            
            let frame = EditorModel.Frame(
                hasDrawing: true,
                thumbnailURL: thumbnailURL)
            
            frames[drawing.frameIndex] = frame
        }
        
        return EditorModel(
            framesPerSecond: framesPerSecond,
            frames: frames)
    }
    
}
