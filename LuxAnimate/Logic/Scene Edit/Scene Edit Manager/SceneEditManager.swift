//
//  SceneEditManager.swift
//

import Foundation

// TODO: Figure out how this is going to work with the new
// async edit manager system??

// This should maybe be a helper object that generates edit
// objects, instead of a "manager" that maintains state.
// Then the only true manager object would be the project
// edit manager. Down the tree, state is contained inside
// each view controller.

protocol SceneEditManagerDelegate: AnyObject {
    
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
    
    func applySceneEdit() { }
    
}
