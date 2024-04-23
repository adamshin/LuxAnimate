//
//  FrameScene.swift
//

import Foundation

struct FrameScene {
    
    // TODO: Figure out how grouped layers will be rendered
    
    struct Layer {
        var size: Size
        var transform: Matrix3
        
        var alpha: Double
        var blendMode: BlendMode
        
        var content: LayerContent
    }
    
    enum LayerContent {
        case drawing(Project.Drawing)
    }
    
    var size: Size
    
    var layers: [Layer]
    
}
