//
//  ProjectManifest.swift
//

import Foundation

enum Project {
    
    // MARK: - Manifest
    
    struct Manifest: Codable {
        var id: String
        var name: String
        var createdAt: Date
        
        var metadata: Metadata
        var content: Content
        
        var assetIDs: Set<String>
    }
    
    // MARK: - Metadata
    
    struct Metadata: Codable {
        var viewportSize: PixelSize
        var viewportMaxSize: PixelSize
        
        var framesPerSecond: Int
    }
    
    // MARK: - Content
    
    struct Content: Codable {
        // TODO: Multiple animation layers, scenes, etc
        var animationLayer: AnimationLayer
    }
    
    struct AnimationLayer: Codable {
        var id: String
        var name: String
        
        var size: PixelSize
        var drawings: [Drawing]
    }
    
    struct Drawing: Codable {
        var id: String
        var frameIndex: Int
        
        var assetIDs: DrawingAssetIDGroup
    }
    
    struct DrawingAssetIDGroup: Codable {
        var full: String
        var medium: String
        var small: String
        
        var all: [String] { [full, medium, small] }
    }
    
}
