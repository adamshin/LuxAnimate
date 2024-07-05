//
//  ProjectSceneEditor.swift
//

import Foundation

protocol ProjectSceneEditorDelegate: AnyObject {
    
    func applyEdit(
        _ e: ProjectSceneEditor,
        newProjectContent: Project.Content,
        newAssets: [ProjectEditor.Asset])
}

class ProjectSceneEditor {
    
    weak var delegate: ProjectSceneEditorDelegate?
    
    private let projectID: String
    private let sceneID: String
    
    private var projectContent: Project.Content
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
        projectContent: Project.Content
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        
        self.projectContent = projectContent
        
        guard let sceneManifest = try Self.loadSceneManifest(
            projectID: projectID,
            sceneID: sceneID,
            projectContent: projectContent)
        else {
            throw InitError.sceneNotFound
        }
        self.sceneManifest = sceneManifest
    }
    
    // MARK: - Data
    
    private static func loadSceneManifest(
        projectID: String,
        sceneID: String,
        projectContent: Project.Content
    ) throws -> Scene.Manifest? {
        
        guard let scene = projectContent.scenes
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
    
    func update(projectContent: Project.Content) throws {
        guard let sceneManifest = try Self.loadSceneManifest(
            projectID: projectID,
            sceneID: sceneID,
            projectContent: projectContent)
        else {
            throw UpdateError.sceneNotFound
        }
        
        self.projectContent = projectContent
        self.sceneManifest = sceneManifest
    }
    
    // MARK: - Edit
    
    func applySceneEdit(
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) throws {
        
        guard let sceneIndex = projectContent.scenes
            .firstIndex(where: { $0.id == sceneID })
        else {
            throw EditError.sceneNotFound
        }
        
        let projectScene = projectContent.scenes[sceneIndex]
        let contentMetadata = projectContent.metadata
        
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
        
        // Add scene manifests to asset list
        var newProjectAssets = newSceneAssets
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneManifestAssetID,
            data: sceneManifestData))
        
        newProjectAssets.append(ProjectEditor.Asset(
            id: sceneRenderManifestAssetID,
            data: sceneRenderManifestData))
        
        // Update scene
        var newProjectScene = projectScene
        
        newProjectScene.manifestAssetID = sceneManifestAssetID
        newProjectScene.renderManifestAssetID = sceneRenderManifestAssetID
        newProjectScene.sceneAssetIDs = newSceneManifest.assetIDs
        
        // Update project content
        var newProjectContent = projectContent
        newProjectContent.scenes[sceneIndex] = newProjectScene
        
        // Apply edit
        delegate?.applyEdit(
            self,
            newProjectContent: newProjectContent,
            newAssets: newProjectAssets)
        
        // Update state
        self.projectContent = newProjectContent
        self.sceneManifest = newSceneManifest
    }
    
}
