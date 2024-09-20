//
//  AnimationLayerContentEditBuilder.swift
//

import Foundation

struct AnimationLayerContentEditBuilder {
    
    struct Edit {
        var layerContent: Scene.AnimationLayerContent
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
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContentEdit: Edit
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        var layer = layer
        layer.content = .animation(layerContentEdit.layerContent)
        
        guard let layerIndex = sceneManifest.layers
            .firstIndex(where: { $0.id == layer.id })
        else {
            throw Error.invalidLayerID
        }
        
        var sceneManifest = sceneManifest
        sceneManifest.layers[layerIndex] = layer
        
        return ProjectEditBuilder.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: sceneManifest,
            newAssets: [])
    }
    
    // MARK: - Animation Layer
    
    static func createDrawing(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> Edit {
        
        guard !layerContent.drawings
            .contains(where: { $0.frameIndex == frameIndex })
        else {
            throw Error.invalidFrameIndex
        }
        
        let drawing = Scene.Drawing(
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
        layerContent: Scene.AnimationLayerContent,
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
        layerContent: Scene.AnimationLayerContent,
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
        layerContent: Scene.AnimationLayerContent,
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
        layerContent: Scene.AnimationLayerContent,
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
