//
//  ImageAssetLoader.swift
//

import Foundation
import Metal

struct ImageAssetLoader {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    static func load(
        projectID: String,
        assetID: String
    ) throws -> MTLTexture {
        
        let url = FileUrlHelper().projectAssetURL(
            projectID: projectID,
            assetID: assetID)
        
        let data = try Data(contentsOf: url)
        let decOutput = try JXLDecoder.decode(data: data)
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = decOutput.width
        texDescriptor.height = decOutput.height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.storageMode = .private
        texDescriptor.usage = [.shaderRead]
        
        let texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        let region = MTLRegionMake2D(
            0, 0,
            decOutput.width,
            decOutput.height)
        
        let bytesPerRow = decOutput.width * 4
        
        try decOutput.data.withUnsafeBytes { data in
            guard let bytes = data.baseAddress else {
                throw Error.emptyData
            }
            texture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: bytes,
                bytesPerRow: bytesPerRow)
        }
        
        return texture
    }
    
}
