//
//  ProjectManifest.swift
//

import Foundation

enum Project {
    
    struct Manifest: Codable {
        var id: String
        var name: String
        var createdAt: Date
        
        var content: Content
        
        var assetIDs: Set<String>
    }
    
    struct Content: Codable {
        var metadata: ContentMetadata
        var sceneRefs: [SceneRef]
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

// MARK: - Asset IDs

extension Project.Manifest {
    
    mutating func updateAssetIDs() {
        assetIDs = getAssetIDs()
    }
    
    private func getAssetIDs() -> Set<String> {
        var assetIDs = Set<String>()
        
        for sceneRef in content.sceneRefs {
            assetIDs.insert(sceneRef.manifestAssetID)
            assetIDs.insert(sceneRef.renderManifestAssetID)
            assetIDs.formUnion(sceneRef.sceneAssetIDs)
        }
        
        return assetIDs
    }
    
}
