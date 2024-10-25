//
//  Scene.swift
//

import Foundation
import Geometry
import Color

enum Scene {
    
    // MARK: - Scene
    
    struct Manifest: Codable {
        var id: String
        
        var frameCount: Int
        var backgroundColor: Color
        
        var layers: [Layer]
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
    }
    
    struct AnimationLayerContent: Codable {
        var drawings: [Drawing]
    }
    
    struct Drawing: Codable {
        var id: String
        var frameIndex: Int
        
        var fullAssetID: String?
        var thumbnailAssetID: String?
    }
    
    // MARK: - Render Manifest
    
    struct RenderManifest: Codable {
        var frameRenderManifests: [String: FrameRenderManifest]
        var frameRenderManifestFingerprintsByFrameIndex: [String]
    }
    
}

// MARK: - Asset IDs

extension Scene.Manifest {
    
    func assetIDs() -> Set<String> {
        var assetIDs = Set<String>()
        
        for layer in layers {
            assetIDs.formUnion(layer.assetIDs())
        }
        
        return assetIDs
    }
    
}

extension Scene.Layer {
    
    func assetIDs() -> Set<String> {
        switch content {
        case .animation(let content):
            return content.assetIDs()
        }
    }
    
}

extension Scene.AnimationLayerContent {
    
    func assetIDs() -> Set<String> {
        var assetIDs = Set<String>()
        
        for drawing in drawings {
            assetIDs.formUnion(drawing.assetIDs())
        }
        
        return assetIDs
    }
    
}

extension Scene.Drawing {
    
    func assetIDs() -> Set<String> {
        let assetIDs = [
            fullAssetID,
            thumbnailAssetID
        ]
        return Set(assetIDs.compactMap { $0 })
    }
    
}
