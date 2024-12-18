//
//  AnimEditorTimelineModel.swift
//

import Foundation

struct AnimEditorTimelineModel {
    
    struct Frame {
        var hasDrawing: Bool
        var assetID: String?
    }
    
    var frames: [Frame]
    
}

extension AnimEditorTimelineModel {
    
    static let empty = Self(frames: [])
    
    static func generate(
        projectID: String,
        sceneManifest: Scene.Manifest,
        layerContent: Scene.AnimationLayerContent
    ) -> Self {
        
        let emptyFrame = Frame(
            hasDrawing: false,
            assetID: nil)
        
        var frames = Array(
            repeating: emptyFrame,
            count: sceneManifest.frameCount)
        
        // Put drawings on frames
        let drawings = layerContent.drawings
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let frame = Frame(
                hasDrawing: true,
                assetID: drawing.thumbnailAssetID)
            
            frames[drawing.frameIndex] = frame
        }
        
        return Self(frames: frames)
    }
    
}

