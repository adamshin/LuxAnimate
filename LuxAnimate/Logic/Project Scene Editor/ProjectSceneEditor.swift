//
//  ProjectSceneEditor.swift
//

import Foundation

protocol ProjectSceneEditorDelegate: AnyObject {
    
    func applyEdit(
        _ e: ProjectSceneEditor,
        newProjectManifest: Project.Manifest,
        newAssets: [ProjectEditor.Asset])
}

class ProjectSceneEditor {
    
    weak var delegate: ProjectSceneEditorDelegate?
    
    private let projectID: String
    private let sceneID: String
    
    private var projectManifest: Project.Manifest
    private var sceneManifest: Scene.Manifest
    
    enum InitError: Error {
        case sceneNotFound
    }
    
    enum UpdateError: Error {
        case sceneNotFound
    }
    
    enum EditError: Error {
        case sceneNotFound
    }
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        projectManifest: Project.Manifest
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        
        self.projectManifest = projectManifest
        
        guard let sceneManifest = try Self.loadSceneManifest(
            projectID: projectID,
            sceneID: sceneID,
            projectManifest: projectManifest)
        else {
            throw InitError.sceneNotFound
        }
        self.sceneManifest = sceneManifest
    }
    
    // MARK: - Data
    
    private static func loadSceneManifest(
        projectID: String,
        sceneID: String,
        projectManifest: Project.Manifest
    ) throws -> Scene.Manifest? {
        
        guard let scene = projectManifest.content.scenes
            .first(where: { $0.id == sceneID })
        else {
            return nil
        }
        
        let sceneManifestURL = FileHelper.shared.projectAssetURL(
            projectID: projectID,
            assetID: scene.manifestAssetID)
        
        let sceneManifestData = try Data(
            contentsOf: sceneManifestURL)
        
        return try JSONFileDecoder.shared.decode(
            Scene.Manifest.self,
            from: sceneManifestData)
    }
    
    // MARK: - Update
    
    func update(projectManifest: Project.Manifest) throws {
        guard let sceneManifest = try Self.loadSceneManifest(
            projectID: projectID,
            sceneID: sceneID,
            projectManifest: projectManifest)
        else {
            throw UpdateError.sceneNotFound
        }
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
    }
    
    // MARK: - Edit
    
    func applySceneEdit(
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) throws {
        
        guard let sceneIndex = projectManifest.content.scenes
            .firstIndex(where: { $0.id == sceneID })
        else {
            throw EditError.sceneNotFound
        }
        
        let projectScene = projectManifest.content.scenes[sceneIndex]
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
        
        // Update scene
        var newProjectScene = projectScene
        
        newProjectScene.manifestAssetID = sceneManifestAssetID
        newProjectScene.renderManifestAssetID = sceneRenderManifestAssetID
        newProjectScene.sceneAssetIDs = newSceneManifest.assetIDs
        
        // Update project manifest
        var newProjectManifest = projectManifest
        projectManifest.content.scenes[sceneIndex] = newProjectScene
        
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
        
        // Update state
        self.projectManifest = newProjectManifest
        self.sceneManifest = newSceneManifest
    }
    
}
