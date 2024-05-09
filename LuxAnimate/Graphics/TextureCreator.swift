//
//  TextureCreator.swift
//

import Metal

struct TextureCreator {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    static func createTexture(
        imageData: Data,
        width: Int,
        height: Int,
        mipMapped: Bool,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = width
        texDescriptor.height = height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.usage = usage
        
        if mipMapped {
            let widthLevels = ceil(log2(Double(width)))
            let heightLevels = ceil(log2(Double(height)))
            let mipCount = max(heightLevels, widthLevels)
            texDescriptor.mipmapLevelCount = Int(mipCount)
        } else {
            texDescriptor.mipmapLevelCount = 1
        }
        
        let texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        try imageData.withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress
            else { throw Error.emptyData }
            
            let region = MTLRegionMake2D(
                0, 0, width, height)
            
            texture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: baseAddress,
                bytesPerRow: bytesPerRow)
        }
        
        if mipMapped {
            let commandBuffer = MetalInterface.shared
                .commandQueue.makeCommandBuffer()!
            
            let encoder = commandBuffer.makeBlitCommandEncoder()!
            encoder.generateMipmaps(for: texture)
            encoder.endEncoding()
            
            commandBuffer.commit()
        }
        
        return texture
    }
    
}
