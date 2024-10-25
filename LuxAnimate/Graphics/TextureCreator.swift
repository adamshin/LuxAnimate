//
//  TextureCreator.swift
//

import Metal

struct TextureCreator {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    static func createTexture(
        pixelData: Data,
        size: PixelSize,
        mipMapped: Bool,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = size.width
        texDescriptor.height = size.height
        texDescriptor.pixelFormat = AppConfig.pixelFormat
        texDescriptor.usage = usage
        
        if mipMapped {
            let widthLevels = ceil(log2(Double(size.width)))
            let heightLevels = ceil(log2(Double(size.height)))
            let mipCount = max(heightLevels, widthLevels)
            texDescriptor.mipmapLevelCount = Int(mipCount)
        } else {
            texDescriptor.mipmapLevelCount = 1
        }
        
        let texture = MetalInterface.shared.device
            .makeTexture(descriptor: texDescriptor)!
        
        let bytesPerPixel = 4
        let bytesPerRow = size.width * bytesPerPixel
        
        try pixelData.withUnsafeBytes { pointer in
            guard let baseAddress = pointer.baseAddress
            else { throw Error.emptyData }
            
            let region = MTLRegionMake2D(
                0, 0, size.width, size.height)
            
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
    
    static func createEmptyTexture(
        size: PixelSize,
        mipMapped: Bool,
        usage: MTLTextureUsage = .shaderRead
    ) throws -> MTLTexture {
        
        let pixelData = Self.emptyPixelData(
            size: size)
        
        return try createTexture(
            pixelData: pixelData,
            size: size,
            mipMapped: mipMapped,
            usage: usage)
        
    }
    
    private static func emptyPixelData(
        size: PixelSize
    ) -> Data {
        let byteCount = size.width * size.height * 4
        return Data(repeating: 0, count: byteCount)
    }
    
}
