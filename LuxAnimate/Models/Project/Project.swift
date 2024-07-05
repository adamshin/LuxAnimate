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
        
        var content: Content
        
        var assetIDs: Set<String>
    }
    
    // MARK: - Content
    
    struct Content: Codable {
        var metadata: ContentMetadata
        var scenes: [Scene]
        
        var nonSceneAssetIDs: Set<String>
    }
    
    struct ContentMetadata: Codable {
        var viewportSize: PixelSize
        var framesPerSecond: Int
    }
    
    struct Scene: Codable {
        var id: String
        var name: String
        
        var manifestAssetID: String
        var renderManifestAssetID: String
        
        var sceneAssetIDs: Set<String>
    }
    
}
