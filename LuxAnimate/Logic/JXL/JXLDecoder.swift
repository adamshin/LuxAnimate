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
        case `internal`
    }
    
    static func decode(data: Data) throws -> Output {
        let output = JXLDecoderShim.decodeImage(from: data)
        
        guard let output else {
            throw DecodingError.internal
        }
        
        return Output(
            data: output.data,
            width: output.width,
            height: output.height)
    }
    
}
