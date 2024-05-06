//
//  LibraryManager.swift
//

import Foundation

private let defaultCanvasSize = PixelSize(
    width: 1920, height: 1080)

private let defaultFramesPerSecond = 24

struct LibraryManager {
    
    struct LibraryProject {
        var id: String
        var url: URL
        var name: String
    }
    
    private let fileManager = FileManager.default
    private let fileUrlHelper = FileUrlHelper()
    
    private let encoder = JSONFileEncoder()
    private let decoder = JSONFileDecoder()
    
    // MARK: - Internal Methods
    
    private func createLibraryDirectoryIfNeeded() throws {
        let url = fileUrlHelper.libraryDirectoryURL
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true)
    }
    
    private func createLibraryManifestIfNeeded() throws {
        try createLibraryDirectoryIfNeeded()
        
        let url = fileUrlHelper.libraryManifestURL
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        
        let libraryManifest = LibraryManifest()
        try setLibraryManifest(libraryManifest)
    }
    
    private func getLibraryManifest() throws -> LibraryManifest {
        try createLibraryManifestIfNeeded()
        
        let url = fileUrlHelper.libraryManifestURL
        let data = try Data(contentsOf: url)
        
        return try decoder.decode(LibraryManifest.self, from: data)
    }
    
    private func setLibraryManifest(
        _ libraryManifest: LibraryManifest
    ) throws {
        let url = fileUrlHelper.libraryManifestURL
        
        let data = try encoder.encode(libraryManifest)
        try data.write(to: url)
    }
    
    // MARK: - Projects
    
    func getProjects() throws -> [LibraryProject] {
        let libraryManifest = try getLibraryManifest()
        
        var projects: [LibraryProject] = []
        
        for manifestProject in libraryManifest.projects {
            let projectID = manifestProject.id
            
            let projectURL = fileUrlHelper
                .projectURL(for: projectID)
            let projectManifestURL = fileUrlHelper
                .projectManifestURL(for: projectID)
            
            guard let projectManifestData = try? Data(
                contentsOf: projectManifestURL)
            else { continue }
            
            guard let projectManifest = try? decoder.decode(
                Project.Manifest.self,
                from: projectManifestData)
            else { continue }
            
            let project = LibraryProject(
                id: projectID,
                url: projectURL,
                name: projectManifest.name)
            
            projects.append(project)
        }
        return projects
    }
    
    func createProject() throws -> String {
        let projectID = UUID().uuidString
        
        let projectURL = fileUrlHelper
            .projectURL(for: projectID)
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        try fileManager.createDirectory(
            at: projectURL,
            withIntermediateDirectories: false)
        
        let projectManifest = createNewProjectManifest(
            id: projectID,
            name: "New Project")
        
        let projectManifestData = try encoder.encode(projectManifest)
        try projectManifestData.write(to: projectManifestURL)
        
        var libraryManifest = try getLibraryManifest()
        let project = LibraryManifest.Project(id: projectID)
        libraryManifest.projects.insert(project, at: 0)
        try setLibraryManifest(libraryManifest)
        
        return projectID
    }
    
    func deleteProject(projectID: String) throws {
        let projectURL = fileUrlHelper
            .projectURL(for: projectID)
        
        try fileManager.removeItem(at: projectURL)
        
        var libraryManifest = try getLibraryManifest()
        if let projectIndex = libraryManifest.projects
            .firstIndex(where: { $0.id == projectID })
        {
            libraryManifest.projects.remove(at: projectIndex)
            try setLibraryManifest(libraryManifest)
        }
    }
    
    // MARK: - Project Manifest
    
    private func createNewProjectManifest(
        id: String,
        name: String
    ) -> Project.Manifest {
        
        let now = Date()
        
        let metadata = Project.Metadata(
            viewportSize: defaultCanvasSize,
            viewportMaxSize: defaultCanvasSize,
            framesPerSecond: defaultFramesPerSecond)
        
        let content = Project.Content(
            animationLayer: Project.AnimationLayer(
                id: UUID().uuidString,
                name: "Layer",
                size: defaultCanvasSize,
                drawings: []))
        
        return Project.Manifest(
            id: id,
            name: name,
            createdAt: now,
            metadata: metadata,
            content: content,
            assetIDs: [])
    }
    
}
