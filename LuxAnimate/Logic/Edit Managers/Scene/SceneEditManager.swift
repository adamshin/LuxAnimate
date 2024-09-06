//
//  SceneEditManager.swift
//

import Foundation

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

protocol SceneEditManagerDelegate: AnyObject {
    
    func applySceneEdit(
        _ m: SceneEditManager,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset])
    
//    func onUpdate(
//        projectManifest: Project.Manifest,
//        sceneManifest: Scene.Manifest)
    
}

class SceneEditManager {
    
    enum Error: Swift.Error {
        case invalidSceneID
        case invalidSceneManifest
    }
    
    private let projectID: String
    private let sceneID: String
    
    private(set) var projectManifest: Project.Manifest
    private(set) var sceneManifest: Scene.Manifest
    
    weak var delegate: SceneEditManagerDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        projectManifest: Project.Manifest
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.projectManifest = projectManifest
        
        guard let sceneRef = projectManifest
            .content.sceneRefs
            .first(where: { $0.id == sceneID })
        else {
            throw Error.invalidSceneID
        }
        
        let sceneManifestURL = FileHelper.shared
            .projectAssetURL(
                projectID: projectID,
                assetID: sceneRef.manifestAssetID)
        
        do {
            let sceneManifestData = try Data(
                contentsOf: sceneManifestURL)
            
            let sceneManifest = try JSONFileDecoder
                .shared.decode(
                    Scene.Manifest.self,
                    from: sceneManifestData)
            
            self.sceneManifest = sceneManifest
            
        } catch {
            throw Error.invalidSceneManifest
        }
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
    }
    
    func createAnimationLayer() {
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
        
        delegate?.applySceneEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: [])
        
        self.sceneManifest = newSceneManifest
        // Notify delegate that data has changed?
    }
    
    func deleteLayer(
        layerID: String
    ) {
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.removeLast()
        
        delegate?.applySceneEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: [])
        
        self.sceneManifest = newSceneManifest
        // Notify delegate that data has changed?
    }
    
}
