//
//  ProjectEditBuilder.swift
//

import Foundation
import Color
import FileCoding

struct ProjectEditBuilder {
    
    struct SceneEdit {
        var sceneID: String
        var sceneManifest: Scene.Manifest
        var newAssets: [ProjectEditManager.NewAsset]
    }
    
    enum Error: Swift.Error {
        case invalidSceneID
    }
    
    // MARK: - Scene Edit
    
    static func applySceneEdit(
        projectManifest: Project.Manifest,
        sceneEdit: SceneEdit
    ) throws -> ProjectEditManager.Edit {
        
        guard let sceneIndex = projectManifest.content.sceneRefs
            .firstIndex(where: { $0.id == sceneEdit.sceneID })
        else {
            throw Error.invalidSceneID
        }
        
        // Build scene render manifest
        let sceneRenderManifest =
            SceneRenderManifestBuilder.build(
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
        var sceneRef = projectManifest.content.sceneRefs[sceneIndex]
        
        sceneRef.manifestAssetID = sceneManifestAssetID
        sceneRef.renderManifestAssetID = sceneRenderManifestAssetID
        
        sceneRef.sceneAssetIDs = sceneEdit.sceneManifest.assetIDs()
        
        // Update project manifest
        var projectManifest = projectManifest
        projectManifest.content.sceneRefs[sceneIndex] = sceneRef
        projectManifest.updateAssetIDs()
        
        // Create new asset list
        var newAssets = sceneEdit.newAssets
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
            newAssets: newAssets)
    }
    
    // MARK: - Scene
    
    static func createScene(
        projectManifest: Project.Manifest,
        name: String,
        frameCount: Int,
        backgroundColor: Color
    ) throws -> ProjectEditManager.Edit {
        
        // Generate scene ID
        let sceneID = IDGenerator.id()
        
        // Create scene manifest
        let sceneManifest = Scene.Manifest(
            id: sceneID,
            frameCount: frameCount,
            backgroundColor: backgroundColor,
            layers: [])
        
        // Build scene render manifest
        let sceneRenderManifest =
            SceneRenderManifestBuilder.build(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest)
        
        // Encode data
        let sceneManifestData = try JSONFileEncoder
            .shared.encode(sceneManifest)
        let sceneRenderManifestData = try JSONFileEncoder
            .shared.encode(sceneRenderManifest)
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        let sceneAssetIDs = sceneManifest.assetIDs()
        
        // Create scene ref
        let sceneRef = Project.SceneRef(
            id: sceneID,
            name: name,
            manifestAssetID: sceneManifestAssetID,
            renderManifestAssetID: sceneRenderManifestAssetID,
            sceneAssetIDs: sceneAssetIDs)
        
        // Update project manifest
        var projectManifest = projectManifest
        projectManifest.content.sceneRefs.append(sceneRef)
        projectManifest.updateAssetIDs()
        
        // Create asset list
        var newAssets: [ProjectEditManager.NewAsset] = []
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
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
        
        var projectManifest = projectManifest
        projectManifest.content.sceneRefs.remove(at: sceneIndex)
        projectManifest.updateAssetIDs()
        
        return ProjectEditManager.Edit(
            projectManifest: projectManifest,
            newAssets: [])
    }
    
}
