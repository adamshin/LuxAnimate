//
//  DrawingAssetProcessor.swift
//

import Metal

struct DrawingAssetProcessor {
    
    private let imageResizer = ImageResizer()
    
    struct ImageSet {
        var full: Data
        var medium: Data
        var small: Data
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
        
        // Resize images
        let mediumImageSize = PixelSize(
            fitting: PixelSize(
                width: AppConfig.assetPreviewMediumSize,
                height: AppConfig.assetPreviewMediumSize),
            aspectRatio: imageAspectRatio)
        
        let smallImageSize = PixelSize(
            fitting: PixelSize(
                width: AppConfig.assetPreviewSmallSize,
                height: AppConfig.assetPreviewSmallSize),
            aspectRatio: imageAspectRatio)
        
        let mediumImageData = try imageResizer.resize(
            imageTexture: sourceTexture,
            targetSize: mediumImageSize)
        
        let smallImageData = try imageResizer.resize(
            imageTexture: sourceTexture,
            targetSize: smallImageSize)
        
        // Encode images
        let fullEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: imageData,
                width: imageWidth,
                height: imageHeight),
            lossless: true,
            quality: 100,
            effort: 1)
        
        let mediumEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: mediumImageData,
                width: mediumImageSize.width,
                height: mediumImageSize.height),
            lossless: false,
            quality: 90,
            effort: 1)
        
        let smallEncodedData = try! JXLEncoder.encode(
            input: .init(
                data: smallImageData,
                width: smallImageSize.width,
                height: smallImageSize.height),
            lossless: false,
            quality: 90,
            effort: 1)
        
        return ImageSet(
            full: fullEncodedData,
            medium: mediumEncodedData,
            small: smallEncodedData)
    }
    
}
