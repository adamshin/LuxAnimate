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
    
    private let libraryDirectoryURL: URL
    private let libraryManifestURL: URL
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initializer
    
    init() throws {
        let documentDirectoryURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        
        libraryDirectoryURL = documentDirectoryURL.appending(
            path: "library",
            directoryHint: .isDirectory)
        
        libraryManifestURL = libraryDirectoryURL.appending(
            path: "manifest")
    }
    
    // MARK: - Internal Methods
    
    private func createLibraryDirectoryIfNeeded() throws {
        if fileManager.fileExists(
            atPath: libraryDirectoryURL.path())
        { return }
        
        try fileManager.createDirectory(
            at: libraryDirectoryURL,
            withIntermediateDirectories: true)
    }
    
    private func createLibraryManifestIfNeeded() throws {
        try createLibraryDirectoryIfNeeded()
        
        if fileManager.fileExists(
            atPath: libraryManifestURL.path())
        { return }
        
        let libraryManifest = LibraryManifest()
        try setLibraryManifest(libraryManifest)
    }
    
    private func getLibraryManifest() throws -> LibraryManifest {
        try createLibraryManifestIfNeeded()
        
        let data = try Data(contentsOf: libraryManifestURL)
        return try decoder.decode(LibraryManifest.self, from: data)
    }
    
    private func setLibraryManifest(
        _ libraryManifest: LibraryManifest
    ) throws {
        let data = try encoder.encode(libraryManifest)
        try data.write(to: libraryManifestURL)
    }
    
    private func projectURL(for projectID: String) -> URL {
        return libraryDirectoryURL.appending(
            path: projectID,
            directoryHint: .isDirectory)
    }
    
    private func projectManifestURL(for projectID: String) -> URL {
        let projectURL = projectURL(for: projectID)
        return projectURL.appending(path: "manifest")
    }
    
    // MARK: - Projects
    
    func getProjects() throws -> [Project] {
        let libraryManifest = try getLibraryManifest()
        
        var projects: [Project] = []
        
        for manifestProject in libraryManifest.projects {
            let projectID = manifestProject.id
            let projectURL = projectURL(for: projectID)
            let projectManifestURL = projectManifestURL(for: projectID)
            
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
        
        let projectURL = projectURL(for: projectID)
        let projectManifestURL = projectManifestURL(for: projectID)
        
        try fileManager.createDirectory(
            at: projectURL,
            withIntermediateDirectories: false)
        
        let now = Date()
        let projectManifest = ProjectManifest(
            name: "New Project",
            createdAt: now,
            modifiedAt: now,
            canvasSize: PixelSize(width: 1000, height: 1000),
            image: nil)
        
        let projectManifestData = try encoder.encode(projectManifest)
        try projectManifestData.write(to: projectManifestURL)
        
        var libraryManifest = try getLibraryManifest()
        let project = LibraryManifest.Project(id: projectID)
        libraryManifest.projects.insert(project, at: 0)
        try setLibraryManifest(libraryManifest)
        
        return projectID
    }
    
}
