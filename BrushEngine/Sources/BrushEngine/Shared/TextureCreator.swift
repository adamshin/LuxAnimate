
import Metal

struct TextureCreator {
    
    enum Error: Swift.Error {
        case emptyData
    }
    
    private let metalDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    init(
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        self.metalDevice = metalDevice
        self.commandQueue = commandQueue
    }
    
    func createTexture(
        width: Int,
        height: Int,
        pixelData: Data,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage,
        mipMapped: Bool
    ) throws -> MTLTexture {
        
        let texDescriptor = MTLTextureDescriptor()
        texDescriptor.width = width
        texDescriptor.height = height
        texDescriptor.pixelFormat = pixelFormat
        texDescriptor.usage = usage
        
        if mipMapped {
            let widthLevels = ceil(log2(Double(width)))
            let heightLevels = ceil(log2(Double(height)))
            let mipCount = max(heightLevels, widthLevels)
            texDescriptor.mipmapLevelCount = Int(mipCount)
        } else {
            texDescriptor.mipmapLevelCount = 1
        }
        
        let texture = metalDevice.makeTexture(
            descriptor: texDescriptor)!
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        try pixelData.withUnsafeBytes { pointer in
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
            let commandBuffer = commandQueue
                .makeCommandBuffer()!
            
            let encoder = commandBuffer
                .makeBlitCommandEncoder()!
            
            encoder.generateMipmaps(for: texture)
            encoder.endEncoding()
            
            commandBuffer.commit()
        }
        
        return texture
    }
    
    func createEmptyTexture(
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage
    ) throws -> MTLTexture {
        
        let pixelData = Self.emptyPixelData(
            width: width,
            height: height)
        
        return try createTexture(
            width: width,
            height: height,
            pixelData: pixelData,
            pixelFormat: pixelFormat,
            usage: usage,
            mipMapped: false)
        
    }
    
    private static func emptyPixelData(
        width: Int,
        height: Int
    ) -> Data {
        let byteCount = width * height * 4
        return Data(repeating: 0, count: byteCount)
    }
    
}
