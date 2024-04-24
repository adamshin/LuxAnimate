//
//  ImageAssetLoader.swift
//

import Foundation
import Metal

struct ImageAssetLoader {
    
    static func load(
        projectID: String,
        assetID: String
    ) throws -> MTLTexture {
        
        let url = FileUrlHelper().projectAssetURL(
            projectID: projectID,
            assetID: assetID)
        
        return try JXLTextureLoader.load(url: url)
    }
    
}
