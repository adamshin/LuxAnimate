//
//  FrameScene.swift
//

import Foundation

struct FrameScene {
    
    struct Layer {
        var width: Scalar
        var height: Scalar
        var transform: Matrix3
        
        var alpha: Double
        var blendMode: BlendMode
        
        var content: LayerContent
    }
    
    enum LayerContent {
        case drawing(Project.Drawing)
        case group([Layer])
    }
    
    var layers: [Layer]
    
}
