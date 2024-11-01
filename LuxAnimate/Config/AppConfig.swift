//
//  AppConfig.swift
//

import Foundation
import Metal
import Color
import BrushEngine

struct AppConfig {
    
    static let pixelFormat: MTLPixelFormat = .bgra8Unorm
    static let metalLayerPixelFormat: MTLPixelFormat = .bgra8Unorm
    
    static let drawingThumbnailSize = 300
    
    static let brushDebugRender = false
    
    static let paintBrushColor = Color.brushBlack
    static let strokeDebugColor = Color.debugRed
    
    static let paintBrushConfig = taperBrushConfig
    
    static let testBrushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 300,
        stampSpacing: 0,
        stampAlpha: 1,
        pressureScaling: 0,
        taperLength: 0.1,
        taperRoundness: 1,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let roundBrushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 200,
        stampSpacing: 0,
        stampAlpha: 1,
        pressureScaling: 0.5,
        taperLength: 0,
        taperRoundness: 0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let taperBrushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 200,
        stampSpacing: 0,
        stampAlpha: 1,
        pressureScaling: 0,
        taperLength: 1.0,
        taperRoundness: 1.0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let penBrushConfig = Brush.Configuration(
        stampTextureName: "brush1.png",
        stampSize: 50,
        stampSpacing: 0.0,
        stampAlpha: 1,
        pressureScaling: 0.3,
        taperLength: 0,
        taperRoundness: 1,
        sizeWobble: 0.1,
        offsetWobble: 0.05,
        wobbleFrequency: 0.7,
        wobblePressureAttenuation: 0.6,
        baseSmoothing: 0.1)
    
    static let wobbleBrushConfig = Brush.Configuration(
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
        wobblePressureAttenuation: 0.5,
        baseSmoothing: 0)
    
    static let arrowBrushConfig = Brush.Configuration(
        stampTextureName: "brush4.png",
        stampSize: 200,
        stampSpacing: 1,
        stampAlpha: 1,
        pressureScaling: 0,
        taperLength: 0,
        taperRoundness: 0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
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
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let onionSkinConfig = AnimEditorOnionSkinConfig(
        prevCount: 5,
        nextCount: 5,
        prevColor: Color(hex: "FF4444"),
        nextColor: Color(hex: "22DD55"),
        alpha: 0.6,
        alphaFalloff: 0.1)
    
}
