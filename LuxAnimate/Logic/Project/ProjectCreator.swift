//
//  ProjectCreator.swift
//

import Foundation

private let defaultCanvasSize = PixelSize(
    width: 1920, 
    height: 1080)

private let defaultFramesPerSecond = 12

struct ProjectCreator {
    
    private let fileManager = FileManager.default
    private let fileURLHelper = FileUrlHelper()
    
    private let encoder = JSONFileEncoder()
    private let decoder = JSONFileDecoder()
    
    func createProject(
        name: String
    ) throws -> String {
        
        let projectID = try createEmptyProject(name: name)
        
        try setupInitialContent(projectID: projectID)
        
        return projectID
    }
    
    private func createEmptyProject(
        name: String
    ) throws -> String {
        
        let projectID = UUID().uuidString
        
        let projectURL = fileURLHelper
            .projectURL(for: projectID)
        let projectManifestURL = fileURLHelper
            .projectManifestURL(for: projectID)
        
        try fileManager.createDirectory(
            at: projectURL,
            withIntermediateDirectories: false)
        
        let projectManifest = createProjectManifest(
            id: projectID,
            name: name)
        
        let projectManifestData = try encoder.encode(projectManifest)
        try projectManifestData.write(to: projectManifestURL)
        
        return projectID
    }
    
    private func createProjectManifest(
        id: String,
        name: String
    ) -> Project.Manifest {
        
        let now = Date()
        
        let metadata = Project.Metadata(
            viewportSize: defaultCanvasSize,
            framesPerSecond: defaultFramesPerSecond)
        
        let animSceneLayerContent = Project.AnimationSceneLayerContent(
            size: defaultCanvasSize,
            drawings: [])
        
        let animSceneLayer = Project.SceneLayer(
            id: UUID().uuidString,
            name: "Layer",
            content: .animation(animSceneLayerContent))
        
        let scene = Project.Scene(
            id: UUID().uuidString,
            name: "Scene",
            frameCount: 100,
            backgroundColor: .white,
            layers: [animSceneLayer])
        
        let content = Project.Content(
            scene: scene)
        
        return Project.Manifest(
            id: id,
            name: name,
            createdAt: now,
            metadata: metadata,
            content: content,
            assetIDs: [])
    }
    
    private func setupInitialContent(
        projectID: String
    ) throws {
        
        let editor = try ProjectEditor(
            projectID: projectID)
        
        try editor.createEmptyDrawing(
            frameIndex: 0)
    }
    
}
