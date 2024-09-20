//
//  DrawingAssetProcessor.swift
//

import Metal
import ImageIO
import UniformTypeIdentifiers

struct DrawingAssetProcessor {
    
    enum Error: Swift.Error {
        case encoding
    }
    
    private let imageResizer = ImageResizer()
    
    struct ImageSet {
        var full: Data
        var thumbnail: Data
    }
    
    func generate(
        sourceTexture: MTLTexture
    ) throws -> ImageSet {
        
        let imageWidth = sourceTexture.width
        let imageHeight = sourceTexture.height
        
        let imageAspectRatio =
            Double(imageWidth) /
            Double(imageHeight)
        
        // Read full data
        let imageData = try TextureDataReader
            .read(sourceTexture)
        
        // Generate thumbnail
        let thumbnailSize = PixelSize(
            fitting: PixelSize(
                width: AppConfig.drawingThumbnailSize,
                height: AppConfig.drawingThumbnailSize),
            aspectRatio: imageAspectRatio)
        
        let thumbnailImageData = try imageResizer.resize(
            imageTexture: sourceTexture,
            targetSize: thumbnailSize)
        
        // Encode images
        let fullEncodedData = try Self.encodePNG(
            imageData: imageData,
            imageWidth: imageWidth,
            imageHeight: imageHeight)
        
        let thumbnailEncodedData = try Self.encodePNG(
            imageData: thumbnailImageData,
            imageWidth: thumbnailSize.width,
            imageHeight: thumbnailSize.height)
        
        return ImageSet(
            full: fullEncodedData,
            thumbnail: thumbnailEncodedData)
    }
    
    private static func encodePNG(
        imageData: Data,
        imageWidth: Int,
        imageHeight: Int
    ) throws -> Data {
        
        guard let outputData = CFDataCreateMutable(nil, 0)
        else {
            throw Error.encoding
        }
        
        guard let destination = CGImageDestinationCreateWithData(
            outputData, UTType.png.identifier as CFString, 1, nil)
        else {
            throw Error.encoding
        }
        
        guard let dataProvider = CGDataProvider(
            data: imageData as CFData)
        else {
            throw Error.encoding
        }
        
        let bitsPerComponent = 8
        let bitsPerPixel = bitsPerComponent * 4
        let bytesPerRow = imageWidth * 4
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)
            .union(.byteOrder32Little)
        
        guard let cgImage = CGImage(
            width: imageWidth,
            height: imageHeight,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            throw Error.encoding
        }
        
        CGImageDestinationAddImage(destination, cgImage, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            throw Error.encoding
        }
        
        return outputData as Data
    }
    
}
