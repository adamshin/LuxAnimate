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
    }
    
    // MARK: - Content
    
    struct Content: Codable {
        var metadata: ContentMetadata
        var scenes: [SceneRef]
    }
    
    struct ContentMetadata: Codable {
        var viewportSize: PixelSize
        var framesPerSecond: Int
    }
    
    struct SceneRef: Codable {
        var id: String
        var name: String
        
        var manifestAssetID: String
        var renderManifestAssetID: String
        
        var sceneAssetIDs: Set<String>
    }
    
}
