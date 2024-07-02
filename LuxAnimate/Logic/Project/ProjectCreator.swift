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
    private let fileURLHelper = FileURLHelper()
    
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
        
        let projectID = IDGenerator.id()
        
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
        
        let content = Project.Content(scenes: [])
        
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
        
        // TODO: Create empty scene and drawing
        
//        let editor = try ProjectContentEditor(
//            projectID: projectID)
//        
//        try editor.createEmptyDrawing(
//            frameIndex: 0)
    }
    
}
