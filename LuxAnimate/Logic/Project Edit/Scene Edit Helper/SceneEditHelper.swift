//
//  SceneEditHelper.swift
//

import Foundation

// Should this be rolled into ProjectEditHelper?
// Should ProjectEditHelper be rolled into ProjectEditManager?

// Maybe the SceneEdit struct should be part of
// ProjectEditManager.

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

struct SceneEditHelper {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
        case invalidDrawingID
    }
    
    // MARK: - Layer
    
    static func createAnimationLayer(
        sceneManifest: Scene.Manifest
    ) -> ProjectEditHelper.SceneEdit {
        
        let drawings = (0 ..< 10).map { index in
            Scene.Drawing(
                id: IDGenerator.id(),
                frameIndex: index,
                assetIDs: nil)
        }
        
        let animationLayerContent = Scene.AnimationLayerContent(
            drawings: drawings)
        
        let transform = Matrix3.identity
        
        let layer = Scene.Layer(
            id: IDGenerator.id(),
            name: "Animation Layer",
            content: .animation(animationLayerContent),
            contentSize: newLayerContentSize,
            transform: transform,
            alpha: 1)
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.append(layer)
        
        return ProjectEditHelper.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: newSceneManifest,
            newAssets: [])
    }
    
    static func deleteLayer(
        sceneManifest: Scene.Manifest,
        layerID: String
    ) throws -> ProjectEditHelper.SceneEdit {
        
        guard let layerIndex = sceneManifest.layers
            .firstIndex(where: { $0.id == layerID })
        else {
            throw Error.invalidLayerID
        }
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.remove(at: layerIndex)
        
        return ProjectEditHelper.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: newSceneManifest,
            newAssets: [])
    }
    
    // MARK: - Animation Layer
    
    static func editDrawing(
        sceneManifest: Scene.Manifest,
        layerID: String,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) throws -> ProjectEditHelper.SceneEdit {
        
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
        
        guard case .animation(var animationLayerContent)
            = layer.content
        else {
            throw Error.invalidLayerContent
        }
        
        var drawings = animationLayerContent.drawings
        
        guard let drawingIndex = drawings
            .firstIndex(where: { $0.id == drawingID })
        else {
            throw Error.invalidDrawingID
        }
        
        var drawing = drawings[drawingIndex]
        let oldAssetIDs = drawing.assetIDs
        drawing.assetIDs = newAssetIDs
        
        drawings[drawingIndex] = drawing
        animationLayerContent.drawings = drawings
        layer.content = .animation(animationLayerContent)
        sceneManifest.layers[layerIndex] = layer
        
        // Update assets
        sceneManifest.assetIDs.subtract(oldAssetIDs?.all ?? [])
        sceneManifest.assetIDs.formUnion(newAssetIDs.all)
        
        // Return
        return ProjectEditHelper.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: sceneManifest,
            newAssets: newAssets)
    }
    
}
