//
//  EditorModel.swift
//

import Foundation
    
struct EditorModel {
    
    struct Frame {
        var hasDrawing: Bool
        var thumbnailURL: URL?
    }
    
    var framesPerSecond: Int
    var frames: [Frame]
    
}

extension EditorModel {
    
    static let empty = EditorModel(
        framesPerSecond: 1,
        frames: [])
    
}
