//
//  JXLEncoder.swift
//

import UIKit

struct JXLEncoder {
    
    enum ImageDataError: Error {
        case invalidInput
        case `internal`
    }
    
    enum EncodingError: Error {
        case unknown
    }
    
    struct ImageData {
        var data: Data
        var width: Int
        var height: Int
    }
    
    static func encode(
        image: UIImage,
        lossless: Bool,
        quality: Int,
        effort: Int
    ) throws -> Data {
        
        let qualityClamped = clamp(quality, min: 0, max: 100)
        let effortClamped = clamp(effort, min: 1, max: 9)
        
        let imageData = try imageData(from: image)
        
        let outputData = JXLEncoderShim.encodeImage(
            with: imageData.data,
            width: imageData.width,
            height: imageData.height,
            lossless: lossless,
            quality: qualityClamped,
            effort: effortClamped)
        
        guard let outputData else {
            throw EncodingError.unknown
        }
        
        return outputData
    }
    
    private static func imageData(
        from image: UIImage
    ) throws -> ImageData {
        
        guard let cgImage = image.cgImage else {
            throw ImageDataError.invalidInput
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
            throw ImageDataError.internal
        }
        
        context.draw(
            cgImage,
            in: CGRect(
                x: 0, y: 0,
                width: width, height: height))
        
        // TODO: un-premultiply alpha!
        
        guard let rawData = context.data else {
            throw ImageDataError.internal
        }
        let data = Data(
            bytes: rawData,
            count: height * bytesPerRow)
        
        return ImageData(
            data: data,
            width: width,
            height: height)
    }
    
}
