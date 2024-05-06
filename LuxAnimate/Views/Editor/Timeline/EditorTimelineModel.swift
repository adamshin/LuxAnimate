//
//  EditorTimelineModel.swift
//

import Foundation
    
struct EditorTimelineModel {
    
    struct Frame {
        var drawing: Drawing?
    }
    
    struct Drawing {
        var id: String
        var thumbnailURL: URL
    }
    
    var frames: [Frame]
}
