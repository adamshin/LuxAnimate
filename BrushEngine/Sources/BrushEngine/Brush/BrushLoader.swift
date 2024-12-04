
import Foundation
import Metal

public struct BrushLoader {
    
    public enum LoadError: Error {
        case manifestNotFound
        case textureNotFound
    }
    
    public static func loadBrush(
        directoryURL: URL,
        metalDevice: MTLDevice
    ) throws -> Brush {
        
        let metadata = try metadata(in: directoryURL)
        
        fatalError()
    }
    
    private static func metadata(
        in directoryURL: URL
    ) throws -> BrushMetadata {
        
        let url = directoryURL
            .appending(path: "metadata")
        
        let data = try Data(contentsOf: url)
        
//        return try JSONFileDecoder.shared.decode
        
        // TODO: We need JSONFileDecoder here.
        // This should be pulled into a package.
        fatalError()
    }
    
    /*
    public init(
        configuration c: BrushConfiguration,
        metalDevice: MTLDevice
    ) throws {
        
        self.configuration = c
        
        guard let shapeTextureURL = Bundle.main.url(
            forResource: c.shapeTextureName,
            withExtension: nil)
        else {
            throw LoadError.textureNotFound
        }
        
        let loader = MTKTextureLoader(device: metalDevice)
        
        shapeTexture = try Self.loadTexture(
            loader: loader,
            url: shapeTextureURL)
        
        if let grainTextureName = c.grainTextureName {
            guard let grainTextureURL = Bundle.main.url(
                forResource: grainTextureName,
                withExtension: nil)
            else {
                throw LoadError.textureNotFound
            }
            
            grainTexture = try Self.loadTexture(
                loader: loader,
                url: grainTextureURL)
        } else {
            grainTexture = nil
        }
    }
    
    private static func loadTexture(
        loader: MTKTextureLoader,
        url: URL
    ) throws -> MTLTexture {
        
        return try loader.newTexture(
            URL: url,
            options: [
                .textureStorageMode: MTLStorageMode.private.rawValue,
                .textureUsage: MTLTextureUsage.shaderRead.rawValue,
                .generateMipmaps: true,
                .SRGB: false,
            ])
    }
     */
    
}
