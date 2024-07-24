//
//  AnimationEditorTimelineModel.swift
//

import Foundation

struct AnimationEditorTimelineModel {
    
    struct Frame {
        var hasDrawing: Bool
        var thumbnailURL: URL?
    }
    
    var framesPerSecond: Int
    var frames: [Frame]
    
}

extension AnimationEditorTimelineModel {
    
    static let empty = AnimationEditorTimelineModel(
        framesPerSecond: 1,
        frames: [])
    
    
    static func generate(
        projectID: String,
        contentMetadata: Project.ContentMetadata,
        sceneManifest: Scene.Manifest,
        animationLayerContent: Scene.AnimationLayerContent
    ) -> AnimationEditorTimelineModel {

        let framesPerSecond = contentMetadata.framesPerSecond

        let emptyFrame = Frame(
            hasDrawing: false,
            thumbnailURL: nil)

        var frames = Array(
            repeating: emptyFrame,
            count: sceneManifest.frameCount)

        // Put drawings on frames
        let drawings = animationLayerContent.drawings
        for drawing in drawings {
            guard frames.indices.contains(drawing.frameIndex)
            else { continue }
            
            let thumbnailURL: URL?
            if let assetIDs = drawing.assetIDs {
                thumbnailURL = FileHelper.shared.projectAssetURL(
                    projectID: projectID,
                    assetID: assetIDs.small)
            } else {
                thumbnailURL = nil
            }
            
            let frame = AnimationEditorTimelineModel.Frame(
                hasDrawing: true,
                thumbnailURL: thumbnailURL)
            
            frames[drawing.frameIndex] = frame
        }
        
        return AnimationEditorTimelineModel(
            framesPerSecond: framesPerSecond,
            frames: frames)
    }
    
}
