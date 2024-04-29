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
        var timeline: Timeline
        
        var assetIDs: Set<String>
    }
    
    // MARK: - Metadata
    
    struct Metadata: Codable {
        var canvasSize: PixelSize
        var framesPerSecond: Int
    }
    
    // MARK: - Timeline
    
    struct Timeline: Codable {
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
        
        var all: [String] {[
            full, 
            medium,
            small
        ]}
    }
    
}
