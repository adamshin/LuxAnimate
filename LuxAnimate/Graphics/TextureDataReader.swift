//
//  TextureDataReader.swift
//

import Metal

struct TextureDataReader {
    
    enum Error: Swift.Error {
        case invalidPixelFormat
    }
    
    static func read(
        _ texture: MTLTexture
    ) throws -> Data {
        
        guard texture.pixelFormat == AppConfig.pixelFormat
        else { throw Error.invalidPixelFormat }
        
        let width = texture.width
        let height = texture.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let size = bytesPerRow * height
        
        let region = MTLRegionMake2D(
            0, 0, width, height)
        
        var data = Data(repeating: 0, count: size)
        
        data.withUnsafeMutableBytes { pointer in
            guard let baseAddress = pointer.baseAddress
            else { return }
            
            texture.getBytes(
                baseAddress,
                bytesPerRow: bytesPerRow,
                from: region,
                mipmapLevel: 0)
        }
        return data
    }
    
}
