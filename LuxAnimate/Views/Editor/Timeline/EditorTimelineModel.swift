//
//  EditorTimelineModel.swift
//

import Foundation
    
struct EditorTimelineModel {
    
    struct Frame {
        var hasDrawing: Bool
        var thumbnailURL: URL?
    }
    
    var framesPerSecond: Int
    var frames: [Frame]
    
}

extension EditorTimelineModel {
    
    static let empty = EditorTimelineModel(
        framesPerSecond: 1,
        frames: [])
    
}
