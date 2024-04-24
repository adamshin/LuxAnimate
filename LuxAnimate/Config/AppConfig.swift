//
//  AppConfig.swift
//

import Foundation
import Metal

struct AppConfig {
    
    static let pixelFormat: MTLPixelFormat = .rgba8Unorm

//    static let brushConfig = Brush.Configuration(
//        stampTextureName: "brush2.png",
//        stampSize: 100,
//        stampSpacing: 0.0,
//        stampAlpha: 1.0,
//        pressureScaling: 1.0,
//        taperLength: 0.02,
//        taperRoundness: 1.0)
    
    static let pressureSensitivity: Double = 1.5
    
    static let strokeGesturePencilOnly = false
    static let strokeGestureUsePredictedTouches = true
    
    static let strokeGestureFingerActivationDelay: TimeInterval = 0.25
    static let strokeGestureFingerActivationDistance: CGFloat = 10
    
    static let strokeGestureEstimateFinalizationDelay: TimeInterval = 0.1
    
    static let brushRenderDebug = false
    
}
