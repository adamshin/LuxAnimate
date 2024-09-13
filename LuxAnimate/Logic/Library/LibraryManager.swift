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
    
    private let projectCreator = ProjectCreator()
    
    // MARK: - Internal Methods
    
    private func createLibraryDirectoryIfNeeded() throws {
        let url = FileHelper.shared.libraryDirectoryURL
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true)
    }
    
    private func createLibraryManifestIfNeeded() throws {
        try createLibraryDirectoryIfNeeded()
        
        let url = FileHelper.shared.libraryManifestURL
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        
        let libraryManifest = LibraryManifest()
        try setLibraryManifest(libraryManifest)
    }
    
    private func getLibraryManifest() throws -> LibraryManifest {
        try createLibraryManifestIfNeeded()
        
        let url = FileHelper.shared.libraryManifestURL
        let data = try Data(contentsOf: url)
        
        return try JSONFileDecoder.shared.decode(LibraryManifest.self, from: data)
    }
    
    private func setLibraryManifest(
        _ libraryManifest: LibraryManifest
    ) throws {
        let url = FileHelper.shared.libraryManifestURL
        
        let data = try JSONFileEncoder.shared.encode(libraryManifest)
        try data.write(to: url)
    }
    
    // MARK: - Projects
    
    func getProjects() throws -> [LibraryProject] {
        let libraryManifest = try getLibraryManifest()
        
        var projects: [LibraryProject] = []
        
        for manifestProject in libraryManifest.projects {
            let projectID = manifestProject.id
            
            let projectURL = FileHelper.shared
                .projectURL(for: projectID)
            let projectManifestURL = FileHelper.shared
                .projectManifestURL(for: projectID)
            
            guard let projectManifestData = try? Data(
                contentsOf: projectManifestURL)
            else { continue }
            
            guard let projectManifest = try? JSONFileDecoder.shared.decode(
                Project.Manifest.self,
                from: projectManifestData)
            else { continue }
            
//            let thumbnailURL: URL? = {
//                guard let layer = projectManifest
//                    .content.scenes.first?.layers.first
//                else { return nil }
//                
//                guard case let .animation(animationLayerContent)
//                    = layer.content
//                else { return nil }
//                
//                guard let firstDrawing = animationLayerContent
//                    .drawings
//                    .sorted(using: KeyPathComparator(\.frameIndex))
//                    .first
//                else { return nil }
//                
//                return FileHelper.shared.projectAssetURL(
//                    projectID: projectID,
//                    assetID: firstDrawing.assetIDs.medium)
//            }()
            
            let project = LibraryProject(
                id: projectID,
                url: projectURL,
                name: projectManifest.name,
                thumbnailURL: nil)
//                thumbnailURL: thumbnailURL)
            
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
        
        let projectManifestURL = FileHelper.shared
            .projectManifestURL(for: projectID)
        
        let projectManifestData = try Data(
            contentsOf: projectManifestURL)
        
        var projectManifest = try JSONFileDecoder.shared.decode(
            Project.Manifest.self,
            from: projectManifestData)
        
        projectManifest.name = name
        
        let newProjectManifestData = try JSONFileEncoder.shared.encode(projectManifest)
        
        try newProjectManifestData
            .write(to: projectManifestURL)
    }
    
    func deleteProject(projectID: String) throws {
        let projectURL = FileHelper.shared
            .projectURL(for: projectID)
        
        let editHistoryDirectoryURL = FileHelper.shared
            .projectEditHistoryDirectoryURL(for: projectID)
        
//        let renderCacheDirectoryURL = FileHelper.shared
//            .renderCacheDirectoryURL(for: projectID)
        
        try? fileManager.removeItem(at: projectURL)
        try? fileManager.removeItem(at: editHistoryDirectoryURL)
//        try fileManager.removeItem(at: renderCacheDirectoryURL)
        
        var libraryManifest = try getLibraryManifest()
        if let projectIndex = libraryManifest.projects
            .firstIndex(where: { $0.id == projectID })
        {
            libraryManifest.projects.remove(at: projectIndex)
            try setLibraryManifest(libraryManifest)
        }
    }
    
}
