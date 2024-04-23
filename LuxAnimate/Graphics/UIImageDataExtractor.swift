//
//  UIImageDataExtractor.swift
//

import UIKit
import Accelerate

struct UIImageDataExtractor {
    
    enum Error: Swift.Error {
        case invalidInput
        case `internal`
    }
    
    struct ImageData {
        var data: Data
        var width: Int
        var height: Int
    }
    
    static func imageData(
        from image: UIImage
    ) throws -> ImageData {
        
        guard let cgImage = image.cgImage else {
            throw Error.invalidInput
        }
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        let width = cgImage.width
        let height = cgImage.height
        
        let bitsPerComponent = 8
        let componentsPerPixel = 4
        let bytesPerRow = componentsPerPixel * width
        
        let bitmapInfo: UInt32 =
            CGImageAlphaInfo.premultipliedLast.rawValue |
            CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo)
        else {
            throw Error.internal
        }
        
        context.draw(
            cgImage,
            in: CGRect(
                x: 0, y: 0,
                width: width, height: height))
        
        guard let rawData = context.data else {
            throw Error.internal
        }
        
        let data = Data(
            bytes: rawData,
            count: height * bytesPerRow)
        
        let dataAdjusted = try unpremultiplyAlpha(
            input: data,
            width: width,
            height: height)
        
        return ImageData(
            data: dataAdjusted,
            width: width,
            height: height)
    }
    
    private static func unpremultiplyAlpha(
        input: Data,
        width: Int,
        height: Int
    ) throws -> Data {
        
        let bytesPerPixel = 4
        let rowByteCount = width * bytesPerPixel
        let byteCount = width * height * bytesPerPixel
        
        guard input.count == byteCount else {
            throw Error.internal
        }
        
        var input = input
        var output = Data(count: byteCount)
        
        input.withUnsafeMutableBytes { inputBytes in
            output.withUnsafeMutableBytes { outputBytes in
                var inputBuffer = vImage_Buffer(
                    data: inputBytes.baseAddress,
                    height: vImagePixelCount(height),
                    width: vImagePixelCount(width),
                    rowBytes: rowByteCount)
                
                var outputBuffer = vImage_Buffer(
                    data: outputBytes.baseAddress,
                    height: vImagePixelCount(height),
                    width: vImagePixelCount(width),
                    rowBytes: rowByteCount)
                
                vImageUnpremultiplyData_RGBA8888(
                    &inputBuffer,
                    &outputBuffer,
                    vImage_Flags(kvImageNoFlags))
            }
        }
        return output
    }
    
}

