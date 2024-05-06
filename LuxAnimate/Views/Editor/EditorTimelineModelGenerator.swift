//
//  EditorTimelineModelGenerator.swift
//

import Foundation

private let displayedFrameCount = 100

struct EditorTimelineModelGenerator {
    
    static func generate(
        from projectManifest: Project.Manifest
    ) -> EditorTimelineModel {
        
        let emptyFrame = EditorTimelineModel.Frame(
            hasDrawing: false)
        
        var frames = Array(
            repeating: emptyFrame,
            count: displayedFrameCount)
        
        let drawings = projectManifest.content.animationLayer.drawings
        
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let frame = EditorTimelineModel.Frame(
                hasDrawing: true)
            
            frames[drawing.frameIndex] = frame
        }
        
        return EditorTimelineModel(frames: frames)
    }
    
}
