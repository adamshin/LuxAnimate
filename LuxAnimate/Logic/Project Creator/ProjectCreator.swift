//
//  ProjectCreator.swift
//

import Foundation
import FileCoding
import Color

private let defaultCanvasSize = PixelSize(
    width: 1920, height: 1080)

private let defaultFramesPerSecond = 12
private let defaultFrameCount = 100

struct ProjectCreator {
    
    private let fileManager = FileManager.default
    
    func createProject(
        name: String
    ) throws -> String {
        
        let projectID = try createEmptyProject(name: name)
        
        return projectID
    }
    
    private func createEmptyProject(
        name: String
    ) throws -> String {
        
        let projectID = IDGenerator.id()
        
        let projectURL = FileHelper.shared
            .projectURL(for: projectID)
        let projectManifestURL = FileHelper.shared
            .projectManifestURL(for: projectID)
        
        try fileManager.createDirectory(
            at: projectURL,
            withIntermediateDirectories: false)
        
        let projectManifest = createProjectManifest(
            id: projectID,
            name: name)
        
        let projectManifestData = try JSONFileEncoder.shared.encode(projectManifest)
        try projectManifestData.write(to: projectManifestURL)
        
        return projectID
    }
    
    private func createProjectManifest(
        id: String,
        name: String
    ) -> Project.Manifest {
        
        let now = Date()
        
        let contentMetadata = Project.ContentMetadata(
            viewportSize: defaultCanvasSize,
            framesPerSecond: defaultFramesPerSecond,
            frameCount: defaultFrameCount,
            backgroundColor: .white)
        
        let renderManifest = Project.RenderManifest(
            frameRenderManifests: [:],
            frameRenderManifestFingerprintsByFrameIndex: [])
        
        let content = Project.Content(
            metadata: contentMetadata,
            layers: [],
            renderManifest: renderManifest)
        
        return Project.Manifest(
            id: id,
            name: name,
            createdAt: now,
            content: content,
            assetIDs: [])
    }
    
}
