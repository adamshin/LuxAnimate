//
//  JXLDecoder.swift
//

import Foundation

struct JXLDecoder {
    
    struct Output {
        var pixelData: Data
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
        
        guard let decoder = JXLDecoderShim(
            inputData: data)
        else {
            throw DecodingError.internal
        }
        
        processLoop: while true {
            guard progress() else { break }
            
            let processResult = decoder.process()
            
            switch processResult {
            case .success: break processLoop
            case .failure: throw DecodingError.internal
            default: break
            }
        }
        
        let output = decoder.output
        return Output(
            pixelData: output.pixelData,
            width: output.width,
            height: output.height)
    }
    
}
