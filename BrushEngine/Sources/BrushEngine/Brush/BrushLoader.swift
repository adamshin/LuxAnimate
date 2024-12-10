
import Foundation
import Metal
import MetalKit
import FileCoding

public struct BrushLoader {
    
    public static func loadBrush(
        id: String,
        url directoryURL: URL,
        metalDevice: MTLDevice
    ) throws -> Brush {
        
        do {
            let textureLoader = MTKTextureLoader(
                device: metalDevice)
            
            let metadata = try metadata(
                in: directoryURL)
            let configuration = try configuration(
                in: directoryURL)
            
            let shapeTexture = try shapeTexture(
                directoryURL: directoryURL,
                textureLoader: textureLoader)
            
            let grainTexture = try grainTexture(
                directoryURL: directoryURL,
                textureLoader: textureLoader)
            
            return Brush(
                id: id,
                metadata: metadata,
                configuration: configuration,
                shapeTexture: shapeTexture,
                grainTexture: grainTexture)
        } catch {
            print(error)
            throw error
        }
    }
    
    private static func metadata(
        in directoryURL: URL
    ) throws -> BrushMetadata {
        
        let url = directoryURL.appending(
            path: "metadata")
        let data = try Data(contentsOf: url)
        
        return try JSONFileDecoder.shared.decode(
            BrushMetadata.self,
            from: data)
    }
    
    private static func configuration(
        in directoryURL: URL
    ) throws -> BrushConfiguration {
        
        let url = directoryURL.appending(
            path: "configuration")
        let data = try Data(contentsOf: url)
        
        let c = try JSONFileDecoder.shared.decode(
            BrushConfigurationCodable.self,
            from: data)
        
        return BrushConfiguration(c)
    }
    
    private static func shapeTexture(
        directoryURL: URL,
        textureLoader: MTKTextureLoader
    ) throws -> MTLTexture {
        
        let url = directoryURL.appending(path: "shape")
        
        return try texture(
            url: url,
            textureLoader: textureLoader)
    }
    
    private static func grainTexture(
        directoryURL: URL,
        textureLoader: MTKTextureLoader
    ) throws -> MTLTexture? {
        
        let url = directoryURL.appending(path: "grain")
        
        guard FileManager.default
            .fileExists(atPath: url.path())
        else { return nil }
        
        return try texture(
            url: url,
            textureLoader: textureLoader)
    }
    
    private static func texture(
        url: URL,
        textureLoader: MTKTextureLoader
    ) throws -> MTLTexture {
        try textureLoader.newTexture(
            URL: url,
            options: [
                .textureStorageMode:
                    MTLStorageMode.private.rawValue,
                .textureUsage:
                    MTLTextureUsage.shaderRead.rawValue,
                .generateMipmaps: true,
                .SRGB: false,
            ])
    }
    
}
