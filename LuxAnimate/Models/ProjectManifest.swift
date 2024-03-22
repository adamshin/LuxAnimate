//
//  ProjectManifest.swift
//

import Foundation

extension ProjectManifest {
    
    struct Drawing: Codable {
        var assetID: String
    }
    
}

struct ProjectManifest: Codable {
    
    var name: String
    var createdAt: Date
    var modifiedAt: Date
    
    var canvasSize: PixelSize
    
    var referencedAssetIDs: Set<String>
    
    var drawings: [Drawing]
    
}
