//
//  AnimEditorTimelineModel.swift
//

import Foundation

struct AnimEditorTimelineModel {
    
    struct Frame {
        var hasDrawing: Bool
        var thumbnailURL: URL?
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
            thumbnailURL: nil)
        
        var frames = Array(
            repeating: emptyFrame,
            count: sceneManifest.frameCount)
        
        // Put drawings on frames
        let drawings = layerContent.drawings
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let thumbnailURL: URL?
            if let thumbnailAssetID = drawing.thumbnailAssetID {
                thumbnailURL = FileHelper.shared.projectAssetURL(
                    projectID: projectID,
                    assetID: thumbnailAssetID)
            } else {
                thumbnailURL = nil
            }
            
            let frame = Frame(
                hasDrawing: true,
                thumbnailURL: thumbnailURL)
            
            frames[drawing.frameIndex] = frame
        }
        
        return Self(frames: frames)
    }
    
}

