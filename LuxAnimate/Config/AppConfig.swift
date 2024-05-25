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
    
    static let paintBrushConfig1 = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 50,
        stampSpacing: 0.0,
        stampAlpha: 1,
        pressureScaling: 0.3,
        taperLength: 0.1,
        taperRoundness: 1.0,
        sizeWobble: 0.1,
        offsetWobble: 0.1,
        wobbleFrequency: 0.5,
        wobblePressureAttenuation: 0.6)
    
    static let paintBrushConfig2 = Brush.Configuration(
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
    
    static let paintBrushConfig3 = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 300,
        stampSpacing: 0,
        stampAlpha: 1,
        pressureScaling: 0.5,
        taperLength: 0,
        taperRoundness: 0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0)
    
    static let paintBrushConfig = paintBrushConfig3
    
    static let eraseBrushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 200,
        stampSpacing: 0.0,
        stampAlpha: 1,
        pressureScaling: 0,
        taperLength: 0,
        taperRoundness: 1,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0)
    
}
