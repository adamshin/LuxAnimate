//
//  EditorTimelineModelGenerator.swift
//

import Foundation

private let displayedFrameCount = 100

struct EditorTimelineModelGenerator {
    
    private let fileUrlHelper = FileUrlHelper()
    
    func generate(
        from projectManifest: Project.Manifest
    ) -> EditorTimelineModel {
        
        let emptyFrame = EditorTimelineModel.Frame(
            drawing: nil)
        
        var frames = Array(
            repeating: emptyFrame,
            count: displayedFrameCount)
        
        let drawings = projectManifest.content.animationLayer.drawings
        
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let thumbnailURL = fileUrlHelper.projectAssetURL(
                projectID: projectManifest.id,
                assetID: drawing.assetIDs.small)
            
            let modelDrawing = EditorTimelineModel.Drawing(
                id: drawing.id,
                thumbnailURL: thumbnailURL)
            
            let frame = EditorTimelineModel.Frame(
                drawing: modelDrawing)
            
            frames[drawing.frameIndex] = frame
        }
        
        return EditorTimelineModel(frames: frames)
    }
    
}
