//
//  LibraryManager.swift
//

import Foundation

struct LibraryManager {
    
    struct LibraryProject {
        var id: String
        var url: URL
        var name: String
        var thumbnailURL: URL?
    }
    
    enum RenameError: Error {
        case invalidName
    }
    
    private let fileManager = FileManager.default
    private let fileUrlHelper = FileUrlHelper()
    
    private let encoder = JSONFileEncoder()
    private let decoder = JSONFileDecoder()
    
    private let projectCreator = ProjectCreator()
    
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
            
            let firstDrawing = projectManifest.content
                .animationLayer
                .drawings
                .sorted { $0.frameIndex < $1.frameIndex }
                .first
            
            let thumbnailURL: URL?
            if let firstDrawing {
                thumbnailURL = fileUrlHelper.projectAssetURL(
                    projectID: projectID,
                    assetID: firstDrawing.assetIDs.medium)
            } else {
                thumbnailURL = nil
            }
            
            let project = LibraryProject(
                id: projectID,
                url: projectURL,
                name: projectManifest.name,
                thumbnailURL: thumbnailURL)
            
            projects.append(project)
        }
        return projects
    }
    
    func createProject(name: String) throws -> String {
        let projectID = try projectCreator
            .createProject(name: name)
        
        var libraryManifest = try getLibraryManifest()
        let project = LibraryManifest.Project(id: projectID)
        libraryManifest.projects.insert(project, at: 0)
        try setLibraryManifest(libraryManifest)
        
        return projectID
    }
    
    func renameProject(
        projectID: String, name: String
    ) throws {
        guard !name.isEmpty else {
            throw RenameError.invalidName
        }
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        let projectManifestData = try Data(
            contentsOf: projectManifestURL)
        
        var projectManifest = try decoder.decode(
            Project.Manifest.self,
            from: projectManifestData)
        
        projectManifest.name = name
        
        let newProjectManifestData = 
            try encoder.encode(projectManifest)
        
        try newProjectManifestData
            .write(to: projectManifestURL)
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
    
}
