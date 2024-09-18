//
//  Scene.swift
//

import Foundation

enum Scene {
    
    // MARK: - Scene
    
    struct Manifest: Codable {
        var id: String
        
        var frameCount: Int
        var backgroundColor: Color
        
        var layers: [Layer]
        
        var assetIDs: Set<String>
    }
    
    struct Layer: Codable {
        var id: String
        var name: String
        
        var content: LayerContent
        var contentSize: PixelSize
        
        var transform: Matrix3
        var alpha: Double
    }
    
    enum LayerContent: Codable {
        case animation(AnimationLayerContent)
        // TODO: Image, video, layer group
    }
    
    struct AnimationLayerContent: Codable {
        var drawings: [Drawing]
    }
    
    struct Drawing: Codable {
        var id: String
        var frameIndex: Int
        
        var fullAssetID: String?
        var thumbnailAssetID: String?
        
        var allAssetIDs: [String] {
            [
                fullAssetID,
                thumbnailAssetID
            ].compactMap { $0 }
        }
    }
    
    // MARK: - Render Manifest
    
    struct RenderManifest: Codable {
        var frameRenderManifests: [String: FrameRenderManifest]
        var frameRenderManifestFingerprintsByFrameIndex: [String]
    }
    
}
