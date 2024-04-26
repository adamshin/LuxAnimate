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
        var modifiedAt: Date
        
        var metadata: Metadata
        var timeline: Timeline
        
        var assetIDs: Set<String>
    }
    
    // MARK: - Metadata
    
    struct Metadata: Codable {
        var contentSize: PixelSize
        var viewportSize: PixelSize
        
        var frameRate: Int
    }
    
    // MARK: - Timeline
    
    struct Timeline: Codable {
        var drawings: [Drawing]
    }
    
    struct Drawing: Codable {
        var id: String
        var frameIndex: Int
        
        var size: PixelSize
        var assetIDs: DrawingAssetIDGroup
    }
    
    struct DrawingAssetIDGroup: Codable {
        var full: String
        var previewMedium: String
        var previewSmall: String
        
        var all: [String] {[
            full, previewMedium, previewSmall
        ]}
    }
    
}
