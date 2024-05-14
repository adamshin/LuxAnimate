//
//  EditorModelGenerator.swift
//

import Foundation

private let displayedFrameCount = 100

struct EditorModelGenerator {
    
    private let fileUrlHelper = FileUrlHelper()
    
    func generate(
        from projectManifest: Project.Manifest
    ) -> EditorModel {
        
        let framesPerSecond = projectManifest.metadata.framesPerSecond
        
        let emptyFrame = EditorModel.Frame(
            hasDrawing: false,
            thumbnailURL: nil)
        
        var frames = Array(
            repeating: emptyFrame,
            count: displayedFrameCount)
        
        // Put drawings on frames
        let drawings = projectManifest.content.animationLayer.drawings
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let thumbnailURL = fileUrlHelper.projectAssetURL(
                projectID: projectManifest.id,
                assetID: drawing.assetIDs.small)
            
            let frame = EditorModel.Frame(
                hasDrawing: true,
                thumbnailURL: thumbnailURL)
            
            frames[drawing.frameIndex] = frame
        }
        
        // Propagate thumbnails forward
        for index in frames.indices.dropFirst() {
            if !frames[index].hasDrawing {
                let thumbnailURL = frames[index - 1].thumbnailURL
                frames[index].thumbnailURL = thumbnailURL
            }
        }
        
        return EditorModel(
            framesPerSecond: framesPerSecond,
            frames: frames)
    }
    
}
