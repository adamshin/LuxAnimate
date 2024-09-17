//
//  AnimationLayerEditBuilder.swift
//

import Foundation

struct AnimationLayerEditBuilder {
    
    struct AnimationLayerContentEdit {
        var layerContent: Scene.AnimationLayerContent
        var newAssets: [ProjectEditManager.NewAsset]
    }
    
    struct DrawingImageSet {
        var full: Data
        var medium: Data
        var small: Data
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
        layerContentEdit: AnimationLayerContentEdit
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
    ) throws -> AnimationLayerContentEdit {
        
        guard !layerContent.drawings
            .contains(where: { $0.frameIndex == frameIndex })
        else {
            throw Error.invalidFrameIndex
        }
        
        let drawing = Scene.Drawing(
            id: IDGenerator.id(),
            frameIndex: frameIndex,
            assetIDs: nil)
        
        var layerContent = layerContent
        layerContent.drawings.append(drawing)
        
        return AnimationLayerContentEdit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func deleteDrawing(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) -> AnimationLayerContentEdit {
        
        var layerContent = layerContent
        var drawings = layerContent.drawings
        
        drawings = drawings.filter { $0.frameIndex != frameIndex }
        layerContent.drawings = drawings
        
        return AnimationLayerContentEdit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func insertSpacing(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) -> AnimationLayerContentEdit {
        
        var drawings = layerContent.drawings
        
        for index in drawings.indices {
            if drawings[index].frameIndex > frameIndex {
                drawings[index].frameIndex += 1
            }
        }
        
        var layerContent = layerContent
        layerContent.drawings = drawings
        
        return AnimationLayerContentEdit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    static func removeSpacing(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int
    ) throws -> AnimationLayerContentEdit {
        
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
        
        return AnimationLayerContentEdit(
            layerContent: layerContent,
            newAssets: [])
    }
    
    // MARK: - Drawing
    
    static func editDrawing(
        sceneManifest: Scene.Manifest,
        layerID: String,
        drawingID: String,
        imageSet: DrawingImageSet
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        // Set up assets
        let fullAssetID = IDGenerator.id()
        let mediumAssetID = IDGenerator.id()
        let smallAssetID = IDGenerator.id()
        
        let newAssets = [
            ProjectEditManager.NewAsset(
                id: fullAssetID,
                data: imageSet.full),
            ProjectEditManager.NewAsset(
                id: mediumAssetID,
                data: imageSet.medium),
            ProjectEditManager.NewAsset(
                id: smallAssetID,
                data: imageSet.small),
        ]
        
        let newAssetIDs = Scene.DrawingAssetIDGroup(
            full: fullAssetID,
            medium: mediumAssetID,
            small: smallAssetID)
        
        // Update drawing
        var sceneManifest = sceneManifest
        
        guard let layerIndex = sceneManifest.layers
            .firstIndex(where: { $0.id == layerID })
        else {
            throw Error.invalidLayerID
        }
        
        var layer = sceneManifest.layers[layerIndex]
        
        guard case .animation(var layerContent)
            = layer.content
        else {
            throw Error.invalidLayerContent
        }
        
        var drawings = layerContent.drawings
        
        guard let drawingIndex = drawings
            .firstIndex(where: { $0.id == drawingID })
        else {
            throw Error.invalidDrawingID
        }
        
        var drawing = drawings[drawingIndex]
        let oldAssetIDs = drawing.assetIDs
        drawing.assetIDs = newAssetIDs
        
        drawings[drawingIndex] = drawing
        layerContent.drawings = drawings
        layer.content = .animation(layerContent)
        sceneManifest.layers[layerIndex] = layer
        
        // Update assets
        sceneManifest.assetIDs.subtract(oldAssetIDs?.all ?? [])
        sceneManifest.assetIDs.formUnion(newAssetIDs.all)
        
        // Return
        return ProjectEditBuilder.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: sceneManifest,
            newAssets: newAssets)
    }
    
}
