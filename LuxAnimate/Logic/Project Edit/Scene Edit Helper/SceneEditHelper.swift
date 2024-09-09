//
//  SceneEditHelper.swift
//

import Foundation

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

struct SceneEditHelper {
    
    enum Error: Swift.Error {
        case invalidLayerID
    }
    
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
    
}
