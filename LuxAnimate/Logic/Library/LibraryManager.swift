//
//  LibraryManager.swift
//

import Foundation

struct LibraryManager {
    
    struct Project {
        var id: String
        var url: URL
        var name: String
    }
    
    private let fileManager = FileManager.default
    private let fileUrlHelper = FileUrlHelper()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
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
    
    func getProjects() throws -> [Project] {
        let libraryManifest = try getLibraryManifest()
        
        var projects: [Project] = []
        
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
                ProjectManifest.self,
                from: projectManifestData)
            else { continue }
            
            let project = Project(
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
        
        let now = Date()
        let canvasSize = PixelSize(width: 1000, height: 1000)
        
        let projectManifest = ProjectManifest(
            name: "New Project",
            createdAt: now,
            modifiedAt: now,
            canvasSize: canvasSize,
            referencedAssetIDs: [],
            drawings: [])
        
        let projectManifestData = try encoder.encode(projectManifest)
        try projectManifestData.write(to: projectManifestURL)
        
        var libraryManifest = try getLibraryManifest()
        let project = LibraryManifest.Project(id: projectID)
        libraryManifest.projects.insert(project, at: 0)
        try setLibraryManifest(libraryManifest)
        
        return projectID
    }
    
}
