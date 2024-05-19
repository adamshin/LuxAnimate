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
        stampSize: 100,
        stampSpacing: 0.0,
        stampAlpha: 1,
        pressureScaling: 0.5,
        taperLength: 0.1,
        taperRoundness: 1.0,
        sizeWobble: 0.4,
        offsetWobble: 0.1,
        wobbleFrequency: 0.25,
        wobblePressureAttenuation: 0.5)
    
}
