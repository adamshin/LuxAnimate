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
        
        let data = try Data(contentsOf: url)
        let image = try JXLDecoder.decode(data: data)
        
        // TODO: Return metal texture!
        fatalError()
    }
    
}
