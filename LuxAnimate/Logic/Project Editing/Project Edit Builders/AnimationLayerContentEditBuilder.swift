//
//  AnimationLayerContentEditBuilder.swift
//

import Foundation

struct AnimationLayerContentEditBuilder {
    
    struct Edit {
        var layerContent: Project.AnimationLayerContent
        var newAssets: [ProjectEditManager.NewAsset]
    }
    
    struct DrawingImageSet {
        var full: Data
        var thumbnail: Data
    }
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
        case invalidDrawingID
        case invalidFrameIndex
    }
    
    // MARK: - Animation Layer Content Edit
    
    static func applyAnimationLayerContentEdit(
        projectManifest: Project.Manifest,
        layer: Project.Layer,
        layerContentEdit: Edit
    ) throws -> ProjectEditBuilder.LayerEdit {
        
        var layer = layer
        layer.content = .animation(layerContentEdit.layerContent)
        
        guard projectManifest.content.layers
            .contains(where: { $0.id == layer.id })
        else {
            throw Error.invalidLayerID
        }
        
        return ProjectEditBuilder.LayerEdit(
            layerID: layer.id,
            layer: layer,
            newAssets: layerContentEdit.newAssets)
    }
    
    // MARK: - Animation Layer
    
    static func createDrawing(
        layerContent: Project.AnimationLayerContent,
        frameIndex: Int
    ) throws -> Edit {
        
        guard !layerContent.drawings
            .contains(where: { $0.frameIndex == frameIndex })
        else {
            throw Error.invalidFrameIndex
        }
        
        let drawing = Project.Drawing(
            id: IDGenerator.id(),
            frameIndex: frameIndex,
            fullAssetID: nil,
            thumbnailAssetID: nil)
        
        var layerContent = layerContent
        layerContent.drawings.append(drawing)
        
        return Edit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func deleteDrawing(
        layerContent: Project.AnimationLayerContent,
        frameIndex: Int
    ) -> Edit {
        
        var layerContent = layerContent
        var drawings = layerContent.drawings
        
        drawings = drawings.filter { $0.frameIndex != frameIndex }
        layerContent.drawings = drawings
        
        return Edit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func insertSpacing(
        layerContent: Project.AnimationLayerContent,
        frameIndex: Int
    ) -> Edit {
        
        var drawings = layerContent.drawings
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndex {
                drawings[index].frameIndex += 1
            }
        }
        
        var layerContent = layerContent
        layerContent.drawings = drawings
        
        return Edit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func removeSpacing(
        layerContent: Project.AnimationLayerContent,
        frameIndex: Int
    ) throws -> Edit {
        
        var drawings = layerContent.drawings
        
        let frameIndexToRemove: Int?
        if !drawings.contains(
            where: { $0.frameIndex == frameIndex })
        {
            frameIndexToRemove = frameIndex
        } else if !drawings.contains(
            where: { $0.frameIndex == frameIndex + 1 })
        {
            frameIndexToRemove = frameIndex + 1
        } else {
            frameIndexToRemove = nil
        }
        guard let frameIndexToRemove else {
            throw Error.invalidFrameIndex
        }
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndexToRemove {
                drawings[index].frameIndex -= 1
            }
        }
        
        var layerContent = layerContent
        layerContent.drawings = drawings
        
        return Edit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    // MARK: - Drawing
    
    static func editDrawing(
        layerContent: Project.AnimationLayerContent,
        drawingID: String,
        imageSet: DrawingImageSet
    ) throws -> Edit {
        
        // Set up assets
        let fullAssetID = IDGenerator.id()
        let thumbnailAssetID = IDGenerator.id()
        
        let newAssets = [
            ProjectEditManager.NewAsset(
                id: fullAssetID,
                data: imageSet.full),
            ProjectEditManager.NewAsset(
                id: thumbnailAssetID,
                data: imageSet.thumbnail),
        ]
        
        // Update drawing
        var drawings = layerContent.drawings
        
        guard let drawingIndex = drawings
            .firstIndex(where: { $0.id == drawingID })
        else {
            throw Error.invalidDrawingID
        }
        
        var drawing = drawings[drawingIndex]
        
        drawing.fullAssetID = fullAssetID
        drawing.thumbnailAssetID = thumbnailAssetID
        
        drawings[drawingIndex] = drawing
        
        // Update layer content
        var layerContent = layerContent
        layerContent.drawings = drawings
        
        // Return
        return Edit(
            layerContent: layerContent,
            newAssets: newAssets)
    }
    
}
