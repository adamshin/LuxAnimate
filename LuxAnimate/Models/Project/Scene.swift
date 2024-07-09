//
//  Scene.swift
//

import Foundation

enum Scene {
    
    // MARK: - Scene
    
    struct Manifest: Codable {
        var frameCount: Int
        var backgroundColor: Color
        
        var layers: [Layer]
        
        var assetIDs: Set<String>
    }
    
    struct Layer: Codable {
        var id: String
        var name: String
        
        var size: PixelSize
        var content: LayerContent
    }
    
    enum LayerContent: Codable {
        case animation(AnimationLayerContent)
        // TODO: Image, video, layer group
    }
    
    struct AnimationLayerContent: Codable {
        var drawings: [Drawing]
    }
    
    struct Drawing: Codable {
        var id: String
        var frameIndex: Int
        
        var assetIDs: DrawingAssetIDGroup?
    }
    
    struct DrawingAssetIDGroup: Codable {
        var full: String
        var medium: String
        var small: String
        
        var all: [String] { [full, medium, small] }
    }
    
    // MARK: - Render Manifest
    
    struct RenderManifest: Codable {
        var frameRenderManifests: [String: FrameRenderManifest]
        var frameRenderManifestFingerprintsByFrameIndex: [String]
    }
    
    struct FrameRenderManifest: Codable {
        
        struct Layer: Codable {
            var size: PixelSize
            var content: LayerContent
        }
        
        enum LayerContent: Codable {
            case drawing(DrawingLayerContent)
        }
        
        struct DrawingLayerContent: Codable {
            var assetIDs: DrawingAssetIDGroup
        }
        
        var viewportSize: PixelSize
        var backgroundColor: Color
        
        var layers: [Layer]
        
    }
    
}

// MARK: - Fingerprint

extension Scene.FrameRenderManifest {
    
    static let jsonEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        e.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan")
        return e
    }()
    
    static let seed1: UInt64 = 0x0123456789ABCDEF
    static let seed2: UInt64 = 0xFEEDFACECAFEBABE
    
    func fingerprint() -> String {
        let encData = try! Self.jsonEncoder.encode(self)
        
        let h1 = XXHash.hash128(data: encData, seed: Self.seed1)
        let h2 = XXHash.hash128(data: encData, seed: Self.seed2)
        
        var data = Data(capacity: 32)
        data.append(h1.low64.data)
        data.append(h1.high64.data)
        data.append(h2.low64.data)
        data.append(h2.high64.data)
        
        return data.base64URLEncodedString()
    }
    
}
