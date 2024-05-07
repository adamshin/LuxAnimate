//
//  EditorTimelineModel.swift
//

import Foundation
    
struct EditorTimelineModel {
    
    struct Frame {
        var hasDrawing: Bool
        var thumbnailURL: URL?
    }
    
    var frames: [Frame]
}
