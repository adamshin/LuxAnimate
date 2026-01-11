//
//  AnimEditorTimelineViewModel.swift
//

import Foundation

struct AnimEditorTimelineViewModel {
    
    struct Frame {
        var hasDrawing: Bool
        var assetID: String?
    }
    
    var frames: [Frame]
    
}

extension AnimEditorTimelineViewModel {
    
    static let empty = Self(frames: [])
    
    init(
        sceneManifest: Scene.Manifest,
        layerContent: Scene.AnimationLayerContent
    ) {
        let emptyFrame = Frame(
            hasDrawing: false,
            assetID: nil)
        
        frames = Array(
            repeating: emptyFrame,
            count: sceneManifest.frameCount)
        
        for drawing in layerContent.drawings {
            guard frames.indices
                .contains(drawing.frameIndex)
            else { continue }
            
            frames[drawing.frameIndex] = Frame(
                hasDrawing: true,
                assetID: drawing.thumbnailAssetID)
        }
    }
    
}
