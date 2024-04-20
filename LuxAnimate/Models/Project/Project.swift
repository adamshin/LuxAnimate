//
//  ProjectManifest.swift
//

import Foundation

enum Project {
    
    // MARK: - Manifest
    
    struct Manifest: Codable {
        var name: String
        var createdAt: Date
        var modifiedAt: Date
        
        var metadata: Metadata
        var timeline: Timeline
        var assets: Assets
    }
    
    // MARK: - Metadata
    
    struct Metadata: Codable {
        var contentWidth: Int
        var contentHeight: Int
        
        var viewportWidth: Int
        var viewportHeight: Int
        
        var frameRate: Int
    }
    
    // MARK: - Timeline
    
    struct Timeline: Codable {
        var animationLayers: [AnimationLayer]
        var drawings: [Drawing]
    }
    
    struct AnimationLayer: Codable {
        var id: String
        var name: String
        
        var width: Scalar
        var height: Scalar
        var pixelScale: Scalar
        
        var drawingLayers: [DrawingLayer]
    }
    
    struct DrawingLayer: Codable {
        var id: String
        var name: String
    }
    
    struct Drawing: Codable {
        var id: String
        
        var frameIndex: Int
        var animationLayerID: String
        var drawingLayerID: String
        
        var assets: DrawingAssetGroup
    }
    
    struct DrawingAssetGroup: Codable {
        var full: String
        var previewMedium: String
        var previewSmall: String
    }
    
    // MARK: - Assets
    
    struct Assets: Codable {
        var assetIDs: Set<String>
    }
    
}
