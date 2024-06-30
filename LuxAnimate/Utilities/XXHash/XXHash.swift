//
//  XXHash.swift
//

import Foundation

enum XXHash {
    
    struct Hash128 {
        var low64: UInt64
        var high64: UInt64
    }
    
    static func hash128(
        data: Data,
        seed: UInt64
    ) -> Hash128 {
        return data.withUnsafeBytes { buffer in
            let hash = XXH3_128bits_withSeed(
                buffer.baseAddress,
                buffer.count,
                seed)
            return Hash128(
                low64: hash.low64,
                high64: hash.high64)
        }
    }
    
}
