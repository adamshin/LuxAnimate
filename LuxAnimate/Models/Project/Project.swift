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
        var framesPerSecond: Int
    }
    
    // MARK: - Content
    
    struct Content: Codable {
        var scenes: [Scene]
    }
    
    struct Scene: Codable {
        var id: String
        var name: String
        
        var frameCount: Int
        var backgroundColor: Color
        
        var layers: [SceneLayer]
    }
    
    struct SceneLayer: Codable {
        var id: String
        var name: String
        
        var content: SceneLayerContent
    }
    
    enum SceneLayerContent: Codable {
        case animation(AnimationSceneLayerContent)
        // TODO: Image, video, layer group
    }
    
    struct AnimationSceneLayerContent: Codable {
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
