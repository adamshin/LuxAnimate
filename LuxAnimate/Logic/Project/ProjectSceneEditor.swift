//
//  ProjectSceneEditor.swift
//

import Foundation

protocol ProjectSceneEditorDelegate: AnyObject {
    func editManager(_ e: ProjectSceneEditor) -> ProjectEditManager
}

class ProjectSceneEditor {
    
    weak var delegate: ProjectSceneEditorDelegate?
    
    private let projectID: String
    private let sceneID: String
    
    private let editManager: ProjectEditManager
    
    private var projectManifest: Project.Manifest
    private var sceneManifest: Project.SceneManifest
    
    enum InitError: Error {
        case sceneNotFound
    }
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        sceneLayerID: String,
        editManager: ProjectEditManager
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.editManager = editManager
        
        self.projectManifest = editManager.projectManifest
        
        guard let scene = projectManifest.content.scenes
            .first(where: { $0.id == sceneID })
        else { throw InitError.sceneNotFound }
        
        let sceneManifestURL = FileHelper.shared.projectAssetURL(
            projectID: projectID,
            assetID: scene.manifestAssetID)
        
        let sceneManifestData = try Data(
            contentsOf: sceneManifestURL)
        
        sceneManifest = try JSONFileDecoder.shared.decode(
            Project.SceneManifest.self,
            from: sceneManifestData)
    }
    
    // MARK: - Edit
    
    func applySceneEdit(
        newSceneManifest: Project.SceneManifest,
        newSceneAssets: [ProjectEditManager.NewAsset]
    ) throws {
        
        let contentMetadata = projectManifest.content.metadata
        
        // Generate scene render manifest
        let sceneRenderManifest = ProjectSceneRenderManifestGenerator
            .generate(
                contentMetadata: contentMetadata,
                sceneManifest: newSceneManifest)
        
        // Encode data
        let sceneManifestData = try JSONFileEncoder.shared.encode(newSceneManifest)
        let sceneRenderManifestData = try JSONFileEncoder.shared.encode(sceneRenderManifest)
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        // Add scene manifests to asset list
        var newAssets = newSceneAssets
        
        let sceneManifestAsset = ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData)
        
        let sceneRenderManifestAsset = ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData)
        
        newAssets.append(sceneManifestAsset)
        newAssets.append(sceneRenderManifestAsset)
        
        // Update project manifest
        var newProjectManifest = projectManifest
        
        var scenes = newProjectManifest.content.scenes
        for i in scenes.indices {
            if scenes[i].id == sceneID {
                newProjectManifest.assetIDs.remove(scenes[i].manifestAssetID)
                newProjectManifest.assetIDs.remove(scenes[i].renderManifestAssetID)
                
                scenes[i].manifestAssetID = sceneManifestAssetID
                scenes[i].renderManifestAssetID = sceneRenderManifestAssetID
            }
        }
        newProjectManifest.content.scenes = scenes
        
        for newAsset in newAssets {
            newProjectManifest.assetIDs.insert(newAsset.id)
        }
        
        // Apply edit
        self.projectManifest = newProjectManifest
        self.sceneManifest = newSceneManifest
        
        try editManager.applyEdit(
            newProjectManifest: newProjectManifest,
            newAssets: newAssets)
    }
    
    // MARK: - Undo/Redo
    
//    var isUndoAvailable: Bool { editManager.isUndoAvailable }
//    var isRedoAvailable: Bool { editManager.isRedoAvailable }
//    
//    func applyUndo() throws -> Bool {
//        try editManager.applyUndo()
//        // TODO: Reload scene manifest. Make sure it still exists
//    }
//    
//    func applyRedo() throws -> Bool {
//        try editManager.applyRedo()
//        // TODO: Reload scene manifest. Make sure it still exists
//    }
    
}
