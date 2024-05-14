//
//  JXLDecoder.swift
//

import UIKit

struct JXLDecoder {
    
    struct Output {
        var data: Data
        var width: Int
        var height: Int
    }
    
    enum DecodingError: Error {
        case cancelled
        case `internal`
    }
    
    static func decode(
        data: Data,
        progress: () -> Bool
    ) throws -> Output {
        
        var isCancelled = false
        
        let output = JXLDecoderShim.decodeImage(
            from: data,
            progress: {
                let shouldContinue = progress()
                isCancelled = !shouldContinue
                return shouldContinue
            })
        
        guard let output else {
            if isCancelled {
                throw DecodingError.cancelled
            } else {
                throw DecodingError.internal
            }
        }
        
        return Output(
            data: output.data,
            width: output.width,
            height: output.height)
    }
    
}
