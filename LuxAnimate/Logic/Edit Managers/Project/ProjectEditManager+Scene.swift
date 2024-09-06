//
//  ProjectEditManager+Scene.swift
//

import Foundation

extension ProjectEditManager {
    
    func createScene(
        name: String,
        frameCount: Int,
        backgroundColor: Color
    ) {
        // Generate scene ID
        let sceneID = IDGenerator.id()
        
        // Create scene manifest
        let sceneManifest = Scene.Manifest(
            id: sceneID,
            frameCount: frameCount,
            backgroundColor: backgroundColor,
            layers: [],
            assetIDs: [])
        
        // Generate scene render manifest
        let sceneRenderManifest = Self
            .generateSceneRenderManifest(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest)
        
        // Encode data
        guard
            let sceneManifestData = try? JSONFileEncoder
                .shared.encode(sceneManifest),
            let sceneRenderManifestData = try? JSONFileEncoder
                .shared.encode(sceneRenderManifest)
        else { return }
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        // Create scene ref
        let newSceneRef = Project.SceneRef(
            id: sceneID,
            name: name,
            manifestAssetID: sceneManifestAssetID,
            renderManifestAssetID: sceneRenderManifestAssetID,
            sceneAssetIDs: sceneManifest.assetIDs)
        
        // Update project manifest
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs.append(newSceneRef)
        
        // Create asset list
        var newProjectAssets: [ProjectEditManager.NewAsset] = []
        
        newProjectAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newProjectAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        applyEdit(
            newProjectManifest: newProjectManifest,
            newAssets: newProjectAssets)
    }
    
    func deleteScene(
        sceneID: String
    ) throws {
        
        guard let sceneIndex = projectManifest.content.sceneRefs
            .firstIndex(where: { $0.id == sceneID })
        else { return }
        
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs.remove(at: sceneIndex)
        
        applyEdit(
            newProjectManifest: newProjectManifest,
            newAssets: [])
    }
    
    func applySceneEdit(
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset]
    ) throws {
        
        guard let sceneIndex = projectManifest.content.sceneRefs
            .firstIndex(where: { $0.id == sceneID })
        else { return }
        
        let sceneRef = projectManifest.content.sceneRefs[sceneIndex]
        
        // Generate scene render manifest
        let sceneRenderManifest = Self
            .generateSceneRenderManifest(
                projectManifest: projectManifest,
                sceneManifest: newSceneManifest)
        
        // Encode data
        let sceneManifestData = try JSONFileEncoder.shared
            .encode(newSceneManifest)
        let sceneRenderManifestData = try JSONFileEncoder.shared
            .encode(sceneRenderManifest)
        
        // Generate asset IDs
        let sceneManifestAssetID = IDGenerator.id()
        let sceneRenderManifestAssetID = IDGenerator.id()
        
        // Update scene ref
        var newSceneRef = sceneRef
        
        newSceneRef.manifestAssetID = sceneManifestAssetID
        newSceneRef.renderManifestAssetID = sceneRenderManifestAssetID
        newSceneRef.sceneAssetIDs = newSceneManifest.assetIDs
        
        // Update project manifest
        var newProjectManifest = projectManifest
        newProjectManifest.content.sceneRefs[sceneIndex] = newSceneRef
        
        // Create asset list
        var newProjectAssets = newSceneAssets
        
        newProjectAssets.append(ProjectEditManager.NewAsset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newProjectAssets.append(ProjectEditManager.NewAsset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        applyEdit(
            newProjectManifest: newProjectManifest,
            newAssets: newProjectAssets)
    }
    
}

// MARK: - Scene Render Manifest

extension ProjectEditManager {
    
    private static func generateSceneRenderManifest(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) -> Scene.RenderManifest {
        
        let frameIndexes = Array(0 ..< sceneManifest.frameCount)
        
        let frameSceneGraphs = FrameSceneGraphGenerator
            .generate(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest,
                frameIndexes: frameIndexes)
        
        var sceneRenderManifest = Scene.RenderManifest(
            frameRenderManifests: [:],
            frameRenderManifestFingerprintsByFrameIndex: [])
        
        for frameSceneGraph in frameSceneGraphs {
            let frameRenderManifest = FrameRenderManifest(
                frameSceneGraph: frameSceneGraph)
            
            let fingerprint = frameRenderManifest.fingerprint()
            
            sceneRenderManifest
                .frameRenderManifests[fingerprint]
                = frameRenderManifest
            
            sceneRenderManifest
                .frameRenderManifestFingerprintsByFrameIndex
                .append(fingerprint)
        }
        
        return sceneRenderManifest
    }
    
}
