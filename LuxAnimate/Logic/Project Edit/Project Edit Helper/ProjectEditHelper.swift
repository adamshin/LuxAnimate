//
//  ProjectEditHelper.swift
//

import Foundation

struct ProjectEditHelper {
    
    struct NewSceneConfig {
        var name: String
        var frameCount: Int
        var backgroundColor: Color
    }
    
    struct SceneEdit {
        var sceneID: String
        var sceneManifest: Scene.Manifest
        var newAssets: [ProjectEditManager.NewAsset]
    }
    
    enum Error: Swift.Error {
        case encoding
        case invalidSceneID
    }
    
    // MARK: - Methods
    
    static func createScene(
        projectManifest: Project.Manifest,
        config: NewSceneConfig
    ) throws -> ProjectEditManager.Edit {
        
        // Generate scene ID
        let sceneID = IDGenerator.id()
        
        // Create scene manifest
        let sceneManifest = Scene.Manifest(
            id: sceneID,
            frameCount: config.frameCount,
            backgroundColor: config.backgroundColor,
            layers: [],
            assetIDs: [])
        
        // Generate scene render manifest
        let sceneRenderManifest = 
            SceneRenderManifestGenerator.generate(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest)
        
        // Encode data
        guard
            let sceneManifestData = try? JSONFileEncoder
                .shared.encode(sceneManifest),
            let sceneRenderManifestData = try? JSONFileEncoder
                .shared.encode(sceneRenderManifest)
        else {
            throw Error.encoding
        }
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        // Create scene ref
        let newSceneRef = Project.SceneRef(
            id: sceneID,
            name: config.name,
            manifestAssetID: sceneManifestAssetID,
            renderManifestAssetID: sceneRenderManifestAssetID,
            sceneAssetIDs: sceneManifest.assetIDs)
        
        // Update project manifest
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs.append(newSceneRef)
        
        // Create asset list
        var newAssets: [ProjectEditManager.NewAsset] = []
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        return ProjectEditManager.Edit(
            projectManifest: newProjectManifest,
            newAssets: newAssets)
    }
    
    static func deleteScene(
        projectManifest: Project.Manifest,
        sceneID: String
    ) throws -> ProjectEditManager.Edit {
        
        guard let sceneIndex = projectManifest.content.sceneRefs
            .firstIndex(where: { $0.id == sceneID })
        else {
            throw Error.invalidSceneID
        }
        
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs.remove(at: sceneIndex)
        
        return ProjectEditManager.Edit(
            projectManifest: newProjectManifest,
            newAssets: [])
    }
    
    static func applySceneEdit(
        projectManifest: Project.Manifest,
        sceneEdit: SceneEdit
    ) throws -> ProjectEditManager.Edit {
        
        guard let sceneIndex = projectManifest.content.sceneRefs
            .firstIndex(where: { $0.id == sceneEdit.sceneID })
        else {
            throw Error.invalidSceneID
        }
        
        let sceneRef = projectManifest.content.sceneRefs[sceneIndex]
        
        // Generate scene render manifest
        let sceneRenderManifest =
            SceneRenderManifestGenerator.generate(
                projectManifest: projectManifest,
                sceneManifest: sceneEdit.sceneManifest)
        
        // Encode data
        let sceneManifestData = try JSONFileEncoder.shared
            .encode(sceneEdit.sceneManifest)
        let sceneRenderManifestData = try JSONFileEncoder.shared
            .encode(sceneRenderManifest)
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        // Update scene ref
        var newSceneRef = sceneRef
        
        newSceneRef.manifestAssetID = sceneManifestAssetID
        newSceneRef.renderManifestAssetID = sceneRenderManifestAssetID
        newSceneRef.sceneAssetIDs = sceneEdit.sceneManifest.assetIDs
        
        // Update project manifest
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs[sceneIndex] = newSceneRef
        
        // Create asset list
        var newAssets = sceneEdit.newAssets
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        return ProjectEditManager.Edit(
            projectManifest: newProjectManifest,
            newAssets: newAssets)
    }
    
}
