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
    
    struct EditHistoryEntry {
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
    
    private var editHistoryUndoEntries: [EditHistoryEntry]
    private var editHistoryRedoEntries: [EditHistoryEntry]
    
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
        
        editHistoryUndoEntries = []
        editHistoryRedoEntries = []
        
        try removeEditHistoryDirectory()
        try createEditHistoryDirectory()
    }
    
    deinit {
        do {
            try removeEditHistoryDirectory()
        } catch { }
    }
    
    // MARK: - Edit History
    
    private func editHistoryDirectoryURL() -> URL {
        fileUrlHelper
            .projectCacheDirectoryURL(for: projectID)
            .appending(path: "editHistory")
    }
    
    private func editHistoryEntryURL(entryID: String) -> URL {
        editHistoryDirectoryURL().appending(
            path: entryID,
            directoryHint: .isDirectory)
    }
    
    private func removeEditHistoryDirectory() throws {
        let url = editHistoryDirectoryURL()
        
        if !fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.removeItem(at: url)
    }
    
    private func createEditHistoryDirectory() throws {
        let url = editHistoryDirectoryURL()
        
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true)
    }
    
    private func createEditHistoryEntryDirectory(
        entryID: String
    ) throws {
        let url = editHistoryEntryURL(entryID: entryID)
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: false)
    }
    
    private func removeEditHistoryEntryDirectory(
        entryID: String
    ) throws {
        let url = editHistoryEntryURL(entryID: entryID)
        try fileManager.removeItem(at: url)
    }
    
    private func trimUndoHistoryToLimit() {
        while editHistoryUndoEntries.count > undoHistoryLimit,
            let lastEntry = editHistoryUndoEntries.last
        {
            do {
                try removeEditHistoryEntryDirectory(
                    entryID: lastEntry.id)
            } catch { }
            
            _ = editHistoryUndoEntries.dropLast()
        }
    }
    
    private func clearRedoHistory() {
        for redoEntry in editHistoryRedoEntries {
            do {
                try removeEditHistoryEntryDirectory(
                    entryID: redoEntry.id)
            } catch { }
        }
        editHistoryRedoEntries = []
    }
    
    // MARK: - Assets
    
    private func assetURL(for assetID: String) -> URL {
        fileUrlHelper
            .projectURL(for: projectID)
            .appending(path: assetID)
    }
    
    private func writeAssetToProjectDirectory(
        _ asset: NewAsset
    ) throws {
        let url = assetURL(for: asset.id)
        try asset.data.write(to: url)
    }
    
    private func moveAssetInProjectToEditHistoryEntryDirectory(
        assetID: String,
        entryID: String
    ) throws {
        let assetURL = assetURL(for: assetID)
        
        let editHistoryEntryURL = editHistoryEntryURL(entryID: entryID)
        let newAssetURL = editHistoryEntryURL.appending(path: assetID)
        
        try fileManager.moveItem(at: assetURL, to: newAssetURL)
    }
    
    // MARK: - Interface
    
    func applyEdit(
        newProjectManifest: ProjectManifest,
        newAssets: [NewAsset]
    ) throws {
        // Setup
        let oldProjectManifest = self.currentProjectManifest
        
        let projectManifestURL = fileUrlHelper
            .projectManifestURL(for: projectID)
        
        let oldProjectManifestData = try Data(
            contentsOf: projectManifestURL)
        
        // Clear redo history
        clearRedoHistory()
        
        // Write new assets to project directory
        for asset in newAssets {
            try writeAssetToProjectDirectory(asset)
        }
        
        // Write new project manifest
        let newProjectManifestData = try encoder.encode(newProjectManifest)
        try newProjectManifestData.write(to: projectManifestURL)
        
        // Update current project manifest
        self.currentProjectManifest = newProjectManifest
        
        // Create new edit history entry
        let editHistoryEntryID = UUID().uuidString
        
        let editHistoryEntryURL = editHistoryEntryURL(
            entryID: editHistoryEntryID)
        
        try createEditHistoryEntryDirectory(entryID: editHistoryEntryID)
        
        // Find any assets referenced in the old manifest but not
        // the new one. Move these to the edit history entry directory
        let oldAssetIDs = Set(oldProjectManifest.referencedAssetIDs)
        let newAssetIDs = Set(newProjectManifest.referencedAssetIDs)
        
        let diffAssetIDs = oldAssetIDs.subtracting(newAssetIDs)
        
        for diffAssetID in diffAssetIDs {
            try moveAssetInProjectToEditHistoryEntryDirectory(
                assetID: diffAssetID,
                entryID: editHistoryEntryID)
        }
        
        // Write old project manifest to edit history folder
        let editHistoryEntryProjectManifestURL = 
            editHistoryEntryURL.appending(path: "manifest")
        
        try oldProjectManifestData.write(
            to: editHistoryEntryProjectManifestURL)
        
        // Add new edit history entry to list
        let newEditHistoryEntry = EditHistoryEntry(id: editHistoryEntryID)
        editHistoryUndoEntries.insert(newEditHistoryEntry, at: 0)
        
        // Trim undo history
        trimUndoHistoryToLimit()
    }
    
    func applyUndo() throws {
        // TODO
    }
    
    func applyRedo() throws {
        // TODO
    }
    
    var isUndoAvailable: Bool { !editHistoryUndoEntries.isEmpty }
    var isRedoAvailable: Bool { !editHistoryRedoEntries.isEmpty }
    
}
