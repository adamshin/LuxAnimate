//
//  ProjectSceneEditHelper.swift
//

import Foundation

protocol ProjectSceneEditHelperDelegate: AnyObject {
    
    func applyEdit(
        _ e: ProjectSceneEditHelper,
        newProjectManifest: Project.Manifest,
        newAssets: [ProjectEditor.Asset])
}

class ProjectSceneEditHelper {
    
    weak var delegate: ProjectSceneEditHelperDelegate?
    
    private let projectID: String
    
    enum EditError: Error {
        case sceneNotFound
    }
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Create Scene
    
    func createScene(
        projectManifest: Project.Manifest,
        name: String,
        frameCount: Int,
        backgroundColor: Color
    ) throws {
        
        let contentMetadata = projectManifest.content.metadata
        
        // Generate scene ID
        let sceneID = IDGenerator.id()
        
        // Create scene manifest
        let sceneManifest = Scene.Manifest(
            frameCount: frameCount,
            backgroundColor: backgroundColor,
            layers: [],
            assetIDs: [])
        
        // Generate scene render manifest
        let sceneRenderManifest = ProjectSceneRenderManifestGenerator
            .generate(
                contentMetadata: contentMetadata,
                sceneManifest: sceneManifest)
        
        // Encode data
        let sceneManifestData = try JSONFileEncoder.shared
            .encode(sceneManifest)
        let sceneRenderManifestData = try JSONFileEncoder.shared
            .encode(sceneRenderManifest)
        
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
        newProjectManifest.content.scenes.append(newSceneRef)
        
        // Create asset list
        var newProjectAssets: [ProjectEditor.Asset] = []
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        delegate?.applyEdit(
            self,
            newProjectManifest: newProjectManifest,
            newAssets: newProjectAssets)
    }
    
    // MARK: - Delete Scene
    
    func deleteScene(
        projectManifest: Project.Manifest,
        sceneID: String
    ) throws {
        
        guard let sceneIndex = projectManifest.content.scenes
            .firstIndex(where: { $0.id == sceneID })
        else {
            throw EditError.sceneNotFound
        }
        
        var newProjectManifest = projectManifest
        newProjectManifest.content.scenes.remove(at: sceneIndex)
        
        delegate?.applyEdit(
            self,
            newProjectManifest: newProjectManifest,
            newAssets: [])
    }
    
    // MARK: - Edit Scene
    
    func applySceneEdit(
        projectManifest: Project.Manifest,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) throws {
        
        guard let sceneIndex = projectManifest.content.scenes
            .firstIndex(where: { $0.id == sceneID })
        else {
            throw EditError.sceneNotFound
        }
        
        let sceneRef = projectManifest.content.scenes[sceneIndex]
        let contentMetadata = projectManifest.content.metadata
        
        // Generate scene render manifest
        let sceneRenderManifest = ProjectSceneRenderManifestGenerator
            .generate(
                contentMetadata: contentMetadata,
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
        newProjectManifest.content.scenes[sceneIndex] = newSceneRef
        
        // Create asset list
        var newProjectAssets = newSceneAssets
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Apply edit
        delegate?.applyEdit(
            self,
            newProjectManifest: newProjectManifest,
            newAssets: newProjectAssets)
    }
    
}
