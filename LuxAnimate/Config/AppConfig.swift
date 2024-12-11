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
    
    static let paintBrushColor = Color.black
    static let strokeDebugColor = Color.debugRed
    
    static let paintBrushID = "pencil"
    static let eraseBrushID = "round"
    
    static let onionSkinConfig = AnimEditorOnionSkinConfig(
        prevCount: 5,
        nextCount: 5,
        prevColor: Color(hex: "FF4444"),
        nextColor: Color(hex: "22DD55"),
        alpha: 0.6,
        alphaFalloff: 0.1)
    
}
