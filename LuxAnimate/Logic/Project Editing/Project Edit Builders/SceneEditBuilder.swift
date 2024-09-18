//
//  SceneEditBuilder.swift
//

import Foundation

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

struct SceneEditBuilder {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
        case invalidDrawingID
    }
    
    static func createAnimationLayer(
        sceneManifest: Scene.Manifest,
        drawingCount: Int
    ) -> ProjectEditBuilder.SceneEdit {
        
        let drawings = (0 ..< drawingCount).map { index in
            Scene.Drawing(
                id: IDGenerator.id(),
                frameIndex: index,
                fullAssetID: nil,
                thumbnailAssetID: nil)
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
        
        var sceneManifest = sceneManifest
        sceneManifest.layers.append(layer)
        
        return ProjectEditBuilder.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: sceneManifest,
            newAssets: [])
    }
    
    static func deleteLayer(
        sceneManifest: Scene.Manifest,
        layerID: String
    ) throws -> ProjectEditBuilder.SceneEdit {
        
        guard let layerIndex = sceneManifest.layers
            .firstIndex(where: { $0.id == layerID })
        else {
            throw Error.invalidLayerID
        }
        
        var sceneManifest = sceneManifest
        sceneManifest.layers.remove(at: layerIndex)
        
        // TODO: Remove old asset IDs!
        // Maybe each layer should maintain its own list of asset IDs?
        // Then when applying a scene edit, we recalculate all asset IDs?
        
        return ProjectEditBuilder.SceneEdit(
            sceneID: sceneManifest.id,
            sceneManifest: sceneManifest,
            newAssets: [])
    }
    
}
