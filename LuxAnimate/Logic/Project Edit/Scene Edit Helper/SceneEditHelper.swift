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
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) throws -> ProjectEditHelper.SceneEdit {
        
        let fullAssetID = IDGenerator.id()
        let mediumAssetID = IDGenerator.id()
        let smallAssetID = IDGenerator.id()
        
        var newSceneManifest = sceneManifest
        
        newSceneManifest.layers = sceneManifest.layers.map { layer in
            guard case .animation(let content) = layer.content
            else { return layer }
            
            let newDrawings = content.drawings.map { drawing in
                guard drawing.id == drawingID
                else { return drawing }
                
                var newDrawing = drawing
                newDrawing.assetIDs = Scene.DrawingAssetIDGroup(
                    full: fullAssetID,
                    medium: mediumAssetID,
                    small: smallAssetID)
                return newDrawing
            }
            var newContent = content
            newContent.drawings = newDrawings
            
            var newLayer = layer
            newLayer.content = .animation(newContent)
            return newLayer
        }
        
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
        
        return ProjectEditHelper.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: newSceneManifest,
            newAssets: newAssets)
    }
    
}
