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
    
    init(
        frameCount: Int,
        layerContent: Project.AnimationLayerContent
    ) {
        let emptyFrame = Frame(
            hasDrawing: false,
            assetID: nil)
        
        frames = Array(
            repeating: emptyFrame,
            count: frameCount)
        
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
