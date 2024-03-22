//
//  ProjectEditor.swift
//

import Foundation

private let undoHistoryLimit = 100

extension ProjectEditor {
    
    struct NewAsset {
        var id: String
        var data: Data
    }
    
    struct HistoryEntry {
        var id: String
    }
    
}

class ProjectEditor {
    
    private let projectID: String
    
    private let fileManager = FileManager.default
    private let fileUrlHelper = FileUrlHelper()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private(set) var currentProjectManifest: ProjectManifest
    
    private var undoHistoryEntries: [HistoryEntry]
    private var redoHistoryEntries: [HistoryEntry]
    
    // MARK: - Initializer
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        let projectManifestData = try Data(
            contentsOf: projectManifestURL)
        
        currentProjectManifest = try decoder.decode(
            ProjectManifest.self,
            from: projectManifestData)
        
        undoHistoryEntries = []
        redoHistoryEntries = []
        
        try removeHistoryDirectory()
        try createHistoryDirectory()
    }
    
    deinit {
        do {
            try removeHistoryDirectory()
        } catch { }
    }
    
    // MARK: - Edit History
    
    private func historyDirectoryURL() -> URL {
        fileUrlHelper
            .projectCacheDirectoryURL(for: projectID)
            .appending(path: "history")
    }
    
    private func historyEntryURL(entryID: String) -> URL {
        historyDirectoryURL().appending(
            path: entryID,
            directoryHint: .isDirectory)
    }
    
    private func removeHistoryDirectory() throws {
        let url = historyDirectoryURL()
        
        if !fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.removeItem(at: url)
    }
    
    private func createHistoryDirectory() throws {
        let url = historyDirectoryURL()
        
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true)
    }
    
    private func createHistoryEntryDirectory(
        entryID: String
    ) throws {
        let url = historyEntryURL(entryID: entryID)
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: false)
    }
    
    private func removeHistoryEntryDirectory(
        entryID: String
    ) throws {
        let url = historyEntryURL(entryID: entryID)
        try fileManager.removeItem(at: url)
    }
    
    private func trimUndoHistoryToLimit() {
        while undoHistoryEntries.count > undoHistoryLimit,
            let lastEntry = undoHistoryEntries.last
        {
            do {
                try removeHistoryEntryDirectory(
                    entryID: lastEntry.id)
            } catch { }
            
            undoHistoryEntries.removeLast()
        }
    }
    
    private func clearRedoHistory() {
        for redoEntry in redoHistoryEntries {
            do {
                try removeHistoryEntryDirectory(
                    entryID: redoEntry.id)
            } catch { }
        }
        redoHistoryEntries = []
    }
    
    // MARK: - Assets
    
    private func assetURLInProject(
        assetID: String
    ) -> URL {
        fileUrlHelper
            .projectURL(for: projectID)
            .appending(path: assetID)
    }
    
    private func assetURLInHistoryEntry(
        assetID: String,
        entryID: String
    ) -> URL {
        historyEntryURL(entryID: entryID)
            .appending(path: assetID)
    }
    
    private func writeAssetToProjectDirectory(
        _ asset: NewAsset
    ) throws {
        let url = assetURLInProject(assetID: asset.id)
        try asset.data.write(to: url)
    }
    
    private func moveAssetInProjectToHistoryEntry(
        assetID: String,
        entryID: String
    ) throws {
        let srcURL = assetURLInProject(
            assetID: assetID)
        
        let dstURL = assetURLInHistoryEntry(
            assetID: assetID,
            entryID: entryID)
        
        try fileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    private func moveAssetInHistoryEntryToProject(
        assetID: String,
        entryID: String
    ) throws {
        let dstURL = assetURLInProject(
            assetID: assetID)
        
        let srcURL = assetURLInHistoryEntry(
            assetID: assetID,
            entryID: entryID)
        
        try fileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    // MARK: - Edit
    
    func applyEdit(
        newProjectManifest: ProjectManifest,
        newAssets: [NewAsset]
    ) throws {
        // Setup
        let oldProjectManifest = self.currentProjectManifest
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        // Clear redo history
        clearRedoHistory()
        
        // Create new history entry
        let historyEntryID = UUID().uuidString
        try createHistoryEntryDirectory(entryID: historyEntryID)
        
        // Copy old project manifest to history entry
        let historyEntryURL = historyEntryURL(
            entryID: historyEntryID)
        
        let historyEntryProjectManifestURL =
            historyEntryURL.appending(
                path: FileUrlHelper.projectManifestFileName)
        
        try fileManager.copyItem(
            at: projectManifestURL,
            to: historyEntryProjectManifestURL)
        
        // Write new assets to project directory
        for asset in newAssets {
            try writeAssetToProjectDirectory(asset)
        }
        
        // Write new project manifest
        let newProjectManifestData = try encoder.encode(newProjectManifest)
        try newProjectManifestData.write(to: projectManifestURL)
        
        // Update current project manifest
        self.currentProjectManifest = newProjectManifest
        
        // Find assets referenced in the old manifest but not the
        // new one. Move these to the new history entry
        let oldAssetIDs = oldProjectManifest.referencedAssetIDs
        let newAssetIDs = newProjectManifest.referencedAssetIDs
        
        let diffAssetIDs = oldAssetIDs.subtracting(newAssetIDs)
        
        for diffAssetID in diffAssetIDs {
            try moveAssetInProjectToHistoryEntry(
                assetID: diffAssetID,
                entryID: historyEntryID)
        }
        
        // Add new edit history entry to list
        let newHistoryEntry = HistoryEntry(id: historyEntryID)
        undoHistoryEntries.insert(newHistoryEntry, at: 0)
        
        // Trim undo history
        trimUndoHistoryToLimit()
    }
    
    // MARK: - Undo/Redo
    
    var isUndoAvailable: Bool { !undoHistoryEntries.isEmpty }
    var isRedoAvailable: Bool { !redoHistoryEntries.isEmpty }
    
    func consumeHistoryEntry(
        entryID consumedHistoryEntryID: String
    ) throws -> String {
        // Setup
        let currentProjectManifest = self.currentProjectManifest
        
        let projectURL = fileUrlHelper.projectURL(for: projectID)
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        let consumedHistoryEntryURL = historyEntryURL(
            entryID: consumedHistoryEntryID)
        
        let consumedProjectManifestURL = consumedHistoryEntryURL
            .appending(path: FileUrlHelper.projectManifestFileName)
        
        let consumedProjectManifestData = try Data(
            contentsOf: consumedProjectManifestURL)
        
        let consumedProjectManifest = try decoder.decode(
            ProjectManifest.self,
            from: consumedProjectManifestData)
        
        // Create new history entry
        let createdHistoryEntryID = UUID().uuidString
        try createHistoryEntryDirectory(entryID: createdHistoryEntryID)
        
        // Copy current project manifest to new history entry
        let createdHistoryEntryURL = historyEntryURL(
            entryID: createdHistoryEntryID)
        
        let createdHistoryEntryProjectManifestURL = createdHistoryEntryURL
            .appending(path: FileUrlHelper.projectManifestFileName)
        
        try fileManager.copyItem(
            at: projectManifestURL,
            to: createdHistoryEntryProjectManifestURL)
        
        // Move asset files from consumed entry to project
        let fileURLs = try fileManager.contentsOfDirectory(
            at: createdHistoryEntryURL,
            includingPropertiesForKeys: nil)
            
        for fileURL in fileURLs {
            let fileName = fileURL.lastPathComponent
            if fileName == FileUrlHelper.projectManifestFileName { continue }
            
            let destinationURL = projectURL
                .appendingPathComponent(fileName)
            
            try fileManager.moveItem(at: fileURL, to: destinationURL)
        }
        
        // Replace project manifest with consumed entry manifest
        let consumedEntryProjectManifestURL = 
            consumedHistoryEntryURL.appending(
                path: FileUrlHelper.projectManifestFileName)
        
        _ = try fileManager.replaceItemAt(
            projectManifestURL,
            withItemAt: consumedEntryProjectManifestURL)
        
        // Update current project manifest
        self.currentProjectManifest = consumedProjectManifest
        
        // Delete the consumed history entry
        try removeHistoryEntryDirectory(entryID: consumedHistoryEntryID)
        
        // Find assets referenced in the old manifest but not the
        // new one. Move these to the new history entry directory
        let oldAssetIDs = currentProjectManifest.referencedAssetIDs
        let newAssetIDs = consumedProjectManifest.referencedAssetIDs
        
        let diffAssetIDs = oldAssetIDs.subtracting(newAssetIDs)
        
        for diffAssetID in diffAssetIDs {
            try moveAssetInProjectToHistoryEntry(
                assetID: diffAssetID,
                entryID: createdHistoryEntryID)
        }
        
        // Return the new entry id
        return createdHistoryEntryID
    }
    
    func applyUndo() throws {
        guard let entry = undoHistoryEntries.first
        else { return }
        
        let newHistoryEntryID = try consumeHistoryEntry(
            entryID: entry.id)
        
        undoHistoryEntries.removeFirst()
        
        let newHistoryEntry = HistoryEntry(id: newHistoryEntryID)
        redoHistoryEntries.insert(newHistoryEntry, at: 0)
    }
    
    func applyRedo() throws {
        guard let entry = redoHistoryEntries.first
        else { return }
        
        let newHistoryEntryID = try consumeHistoryEntry(
            entryID: entry.id)
        
        redoHistoryEntries.removeFirst()
        
        let newHistoryEntry = HistoryEntry(id: newHistoryEntryID)
        undoHistoryEntries.insert(newHistoryEntry, at: 0)
    }
    
}
