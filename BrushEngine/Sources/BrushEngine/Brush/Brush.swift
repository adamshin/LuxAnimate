
import Metal

// MARK: - Brush

public struct Brush {
    
    public var id: String
    public var metadata: BrushMetadata
    public var configuration: BrushConfiguration
    
    public var shapeTexture: MTLTexture
    public var grainTexture: MTLTexture?
    
}

// MARK: - Brush Metadata

public struct BrushMetadata: Codable, Sendable {
    
    public var name: String
    
}
