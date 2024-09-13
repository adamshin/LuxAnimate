//
//  JXLEncoder.swift
//

import Foundation

struct JXLEncoder {
    
    struct Input {
        var data: Data
        var width: Int
        var height: Int
    }
    
    enum EncodingError: Error {
        case `internal`
    }
    
    static func encode(
        input: Input,
        lossless: Bool,
        quality: Int,
        effort: Int
    ) throws -> Data {
        
        let qualityClamped = clamp(quality, min: 0, max: 100)
        let effortClamped = clamp(effort, min: 1, max: 9)
        
        let outputData = JXLEncoderShim.encodeImage(
            with: input.data,
            width: input.width,
            height: input.height,
            lossless: lossless,
            quality: qualityClamped,
            effort: effortClamped)
        
        guard let outputData else {
            throw EncodingError.internal
        }
        
        return outputData
    }
    
}
