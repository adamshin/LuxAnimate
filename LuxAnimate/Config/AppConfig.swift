//
//  AppConfig.swift
//

import Foundation
import Metal

struct AppConfig {
    
    static let pixelFormat: MTLPixelFormat = .rgba8Unorm
    static let metalLayerPixelFormat: MTLPixelFormat = .bgra8Unorm
    
    static let assetPreviewMediumSize = 1200
    static let assetPreviewSmallSize = 300
    
    static let brushRenderDebug = false
    
    static let brushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 50,
        stampSpacing: 0.0,
        stampAlpha: 1,
        pressureScaling: 2.0,
        taperLength: 0.1,
        taperRoundness: 1.0)
    
}
