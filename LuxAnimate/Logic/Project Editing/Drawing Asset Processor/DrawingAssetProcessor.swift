//
//  DrawingAssetProcessor.swift
//

import Metal

struct DrawingAssetProcessor {
    
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
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageWidth,
                height: imageHeight),
            lossless: true,
            quality: 100,
            effort: 1)
        
        let thumbnailEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: thumbnailImageData,
                width: thumbnailSize.width,
                height: thumbnailSize.height),
            lossless: false,
            quality: 90,
            effort: 1)
        
        return ImageSet(
            full: fullEncodedData,
            thumbnail: thumbnailEncodedData)
    }
    
}
