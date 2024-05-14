//
//  FrameScene.swift
//

import Foundation

struct FrameScene {
    
    var backgroundColor: Color
    var layers: [FrameSceneLayer]
    
}

enum FrameSceneLayer {
    case drawing(FrameSceneDrawingLayer)
}

struct FrameSceneDrawingLayer {
    
    var drawing: Project.Drawing
    
}
