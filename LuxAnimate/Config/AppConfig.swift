//
//  AppConfig.swift
//

import Foundation
import Metal

struct AppConfig {
    
    static let pixelFormat: MTLPixelFormat = .rgba8Unorm
    static let metalLayerPixelFormat: MTLPixelFormat = .bgra8Unorm
    
    static let assetPreviewMediumSize = 500//1200
    static let assetPreviewSmallSize = 300
    
    static let brushRenderDebug = false
    
}
