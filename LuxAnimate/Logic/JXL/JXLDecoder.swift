//
//  JXLDecoder.swift
//

import UIKit

struct JXLDecoder {
    
    enum DecodingError: Error {
        case `internal`
    }
    
    static func decode(data: Data) throws -> UIImage {
        let output = JXLDecoderShim.decodeImage(from: data)
        
        guard let output else {
            throw DecodingError.internal
        }
        
        let cgImage = try cgImage(from: output)
        
        return UIImage(cgImage: cgImage)
    }
    
    private static func cgImage(
        from output: JXLDecoderShimOutput
    ) throws -> CGImage {
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        let width = output.width
        
        let bitsPerComponent = 8
        let componentsPerPixel = 4
        let bitsPerPixel = bitsPerComponent * componentsPerPixel
        let bytesPerRow = componentsPerPixel * width
        
        let bitmapInfo: UInt32 =
            CGImageAlphaInfo.last.rawValue |
            CGBitmapInfo.byteOrder32Big.rawValue
        
        let dataProvider = CGDataProvider(data: output.data as CFData)
        guard let dataProvider else {
            throw DecodingError.internal
        }
        
        let cgImage = CGImage(
            width: output.width,
            height: output.height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent)
        
        guard let cgImage else {
            throw DecodingError.internal
        }
        return cgImage
    }
    
}
