//
//  FrameRenderManifest.swift
//

import Foundation

struct FrameRenderManifest: Codable {
        
    var frameSceneGraph: FrameSceneGraph
    
}

// MARK: - Fingerprint

extension FrameRenderManifest {
    
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
