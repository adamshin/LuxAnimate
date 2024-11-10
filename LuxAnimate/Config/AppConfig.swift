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
    
    static let paintBrushColor = Color.brushDarkGray
    static let strokeDebugColor = Color.debugRed
    
    static let paintBrushConfig = inkBrushConfig
    
    static let pencilBrushConfig = BrushConfiguration(
        shapeTextureName: "brush-pencil-3.png",
        textureTextureName: "noise4.png",
        stampSize: 60,
        stampSpacing: 0.1,
        stampOpacity: 0.25,
        stampCount: 2,
        stampPositionJitter: 0.05,
        stampRotationJitter: 0.2,
        stampSizeJitter: 0.3,
        stampOpacityJitter: 0.2,
        pressureSize: 0.95,
        pressureStampOpacity: 0.5,
        taperLength: 0.1,
        taperRoundness: 0.9,
        taperSize: 0.8,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        stampRotationMode: .azimuth,
        baseSmoothing: 0)
    
    static let inkBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 100,
        stampSpacing: 0,
        stampOpacity: 1,
        pressureSize: 1.0,
        taperLength: 0, //0.2,
        taperRoundness: 0, //0.8,
        taperSize: 0, //1,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0) //0.1)
    
    static let roundBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 200,
        stampSpacing: 0,
        stampOpacity: 1,
        pressureSize: 0.5,
        taperLength: 0,
        taperRoundness: 0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let taperBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 200,
        stampSpacing: 0,
        stampOpacity: 1,
        pressureSize: 0,
        taperLength: 1.0,
        taperRoundness: 1.0,
        taperSize: 1,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let penBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 30,
        stampSpacing: 0.0,
        stampOpacity: 1,
        pressureSize: 0.4,
        taperLength: 0.1,
        taperRoundness: 1,
        taperSize: 1,
        sizeWobble: 0.15,
        offsetWobble: 0.05,
        wobbleFrequency: 0.5,
        wobblePressureAttenuation: 0.5,
        baseSmoothing: 0.1)
    
    static let wobbleBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 100,
        stampSpacing: 0.0,
        stampOpacity: 1,
        pressureSize: 0.5,
        taperLength: 0.4,
        taperRoundness: 1.0,
        taperSize: 1,
        sizeWobble: 0.4,
        offsetWobble: 0.1,
        wobbleFrequency: 0.25,
        wobblePressureAttenuation: 0.5,
        baseSmoothing: 0)
    
    static let arrowBrushConfig = BrushConfiguration(
        shapeTextureName: "brush4.png",
        textureTextureName: nil,
        stampSize: 200,
        stampSpacing: 1,
        stampOpacity: 1,
        pressureSize: 0,
        taperLength: 0,
        taperRoundness: 0,
        sizeWobble: 0,
        offsetWobble: 0,
        wobbleFrequency: 0,
        wobblePressureAttenuation: 0,
        baseSmoothing: 0)
    
    static let eraseBrushConfig = BrushConfiguration(
        shapeTextureName: "brush1.png",
        textureTextureName: nil,
        stampSize: 200,
        stampSpacing: 0.0,
        stampOpacity: 1,
        pressureSize: 0,
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
