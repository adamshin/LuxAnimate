//
//  ProjectEditManager.swift
//

import Foundation

private let editHistoryLimit = 20

extension ProjectEditManager {
    
    struct NewAsset {
        var id: String
        var data: Data
    }
    
}

class ProjectEditManager {
    
    private let projectID: String
    
    private(set) var projectManifest: Project.Manifest
    
    private(set) var availableUndoCount: Int = 0
    private(set) var availableRedoCount: Int = 0
    
    private let workQueue = ProjectEditManagerWorkQueue()
    private let fileManager = FileManager.default
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        // Project manifest
        let projectManifestURL = FileHelper.shared
            .projectManifestURL(for: projectID)
        
        let projectManifestData = try Data(
            contentsOf: projectManifestURL)
        
        projectManifest = try JSONFileDecoder.shared.decode(
            Project.Manifest.self,
            from: projectManifestData)
        
        // Edit history
        try createEditHistoryDirectoriesIfNeeded()
        
        updateAvailableUndoRedoCount()
    }
    
    // MARK: - Edit History
    
    private func projectEditHistoryDirectoryURL() -> URL {
        FileHelper.shared.projectEditHistoryDirectoryURL(
            for: projectID)
    }
    
    private func undoHistoryDirectoryURL() -> URL {
        projectEditHistoryDirectoryURL().appending(
            path: "undo",
            directoryHint: .isDirectory)
    }
    
    private func redoHistoryDirectoryURL() -> URL {
        projectEditHistoryDirectoryURL().appending(
            path: "redo",
            directoryHint: .isDirectory)
    }
    
    private func undoEntryCount() -> Int {
        editHistoryEntryCount(in: undoHistoryDirectoryURL())
    }
    
    private func redoEntryCount() -> Int {
        editHistoryEntryCount(in: redoHistoryDirectoryURL())
    }
    
    private func editHistoryEntryCount(in directoryURL: URL) -> Int {
        let contents = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles])
        
        return contents?.count ?? 0
    }
    
    private func createEditHistoryDirectoriesIfNeeded() throws {
        let urls = [
            projectEditHistoryDirectoryURL(),
            undoHistoryDirectoryURL(),
            redoHistoryDirectoryURL(),
        ]
        
        for url in urls {
            if !fileManager.fileExists(atPath: url.path()) {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true)
            }
        }
    }
    
    private func adjustAllEditHistoryEntries(
        in containingDirectoryURL: URL,
        increment: Bool,
        maxCount: Int
    ) throws {
        
        let urls = try fileManager.contentsOfDirectory(
            at: containingDirectoryURL,
            includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles])
        
        var urlsAndIndexes: [(URL, Int)] = urls.compactMap { url in
            guard let index = Int(url.lastPathComponent)
            else { return nil }
            
            return (url, index)
        }
        
        urlsAndIndexes.sort(
            using: KeyPathComparator(
                \.1,
                 order: increment ? .reverse : .forward))
        
        for (url, index) in urlsAndIndexes {
            let newIndex = increment ? index + 1 : index - 1
            
            if newIndex > maxCount - 1 {
                try fileManager.removeItem(at: url)
                continue
            }
            
            let newURL = url
                .deletingLastPathComponent()
                .appending(
                    path: String(newIndex),
                    directoryHint: .isDirectory)
            
            try fileManager.moveItem(at: url, to: newURL)
        }
    }
    
    private func removeAllEditHistoryEntries(
        in containingDirectoryURL: URL
    ) throws {
        
        let urls = try fileManager.contentsOfDirectory(
            at: containingDirectoryURL,
            includingPropertiesForKeys: [])
        
        for url in urls {
            try fileManager.removeItem(at: url)
        }
    }
    
    private func pushNewEditHistoryEntry(
        in containingDirectoryURL: URL
    ) throws -> URL {
        
        try adjustAllEditHistoryEntries(
            in: containingDirectoryURL,
            increment: true,
            maxCount: editHistoryLimit)
        
        let url = containingDirectoryURL.appending(
            path: String(0),
            directoryHint: .isDirectory)
        
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: false)
        
        return url
    }
    
    private func popFirstEditHistoryEntry(
        in containingDirectoryURL: URL
    ) throws {
        
        guard let url = firstEditHistoryEntryURL(
            in: containingDirectoryURL)
        else { return }
        
        if fileManager.fileExists(atPath: url.path()) {
            try fileManager.removeItem(at: url)
        }
        
        try adjustAllEditHistoryEntries(
            in: containingDirectoryURL,
            increment: false,
            maxCount: editHistoryLimit)
    }
    
    private func firstEditHistoryEntryURL(
        in containingDirectoryURL: URL
    ) -> URL? {
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: containingDirectoryURL,
            includingPropertiesForKeys: [],
            options: [.skipsHiddenFiles])
        else { return nil }
        
        let urlsAndIndexes: [(URL, Int)] = urls.compactMap { url in
            guard let index = Int(url.lastPathComponent)
            else { return nil }
            
            return (url, index)
        }
        
        return urlsAndIndexes.min { $0.1 < $1.1 }?.0
    }
    
    private func updateAvailableUndoRedoCount() {
        availableUndoCount = undoEntryCount()
        availableRedoCount = redoEntryCount()
    }
    
    // MARK: - Assets
    
    private func assetURLInProject(
        assetID: String
    ) -> URL {
        FileHelper.shared
            .projectURL(for: projectID)
            .appending(path: assetID)
    }
    
    private func assetURLInEditHistoryEntry(
        assetID: String,
        entryURL: URL
    ) -> URL {
        entryURL.appending(path: assetID)
    }
    
    private func writeAssetToProject(
        _ asset: NewAsset
    ) throws {
        let url = assetURLInProject(assetID: asset.id)
        try asset.data.write(to: url)
    }
    
    private func moveAssetInProjectToEditHistoryEntry(
        assetID: String,
        entryURL: URL
    ) throws {
        
        let srcURL = assetURLInProject(
            assetID: assetID)
        
        let dstURL = assetURLInEditHistoryEntry(
            assetID: assetID,
            entryURL: entryURL)
        
        try fileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    private func moveAssetInEditHistoryEntryToProject(
        assetID: String,
        entryURL: URL
    ) throws {
        let dstURL = assetURLInProject(
            assetID: assetID)
        
        let srcURL = assetURLInEditHistoryEntry(
            assetID: assetID,
            entryURL: entryURL)
        
        try fileManager.moveItem(at: srcURL, to: dstURL)
    }
    
    private static func allAssetIDs(
        in projectManifest: Project.Manifest
    ) -> Set<String> {
        
        var assetIDs = Set<String>()
        
        for sceneRef in projectManifest.content.sceneRefs {
            assetIDs.insert(sceneRef.manifestAssetID)
            assetIDs.insert(sceneRef.renderManifestAssetID)
            assetIDs = assetIDs.union(sceneRef.sceneAssetIDs)
        }
        
        return assetIDs
    }
    
    // MARK: - Internal Logic
    
    private func applyEditInternal(
        newProjectManifest: Project.Manifest,
        newAssets: [NewAsset]
    ) throws {
        
        // Setup
        let oldProjectManifest = self.projectManifest
        
        let projectManifestURL = FileHelper.shared
            .projectManifestURL(for: projectID)
        
        // Clear redo history
        try removeAllEditHistoryEntries(
            in: redoHistoryDirectoryURL())
        
        // Create new undo history entry
        let entryURL = try pushNewEditHistoryEntry(
            in: undoHistoryDirectoryURL())
        
        // Copy old project manifest to history entry
        let historyEntryProjectManifestURL =
            entryURL.appending(
                path: FileHelper.projectManifestFileName)
        
        try fileManager.copyItem(
            at: projectManifestURL,
            to: historyEntryProjectManifestURL)
        
        // Write new assets to project directory
        let oldAssetIDs = Self.allAssetIDs(in: oldProjectManifest)
        let newAssetIDs = Self.allAssetIDs(in: newProjectManifest)
        
        for asset in newAssets {
            guard newAssetIDs.contains(asset.id)
            else { continue }
            
            try writeAssetToProject(asset)
        }
        
        // Write new project manifest
        let newProjectManifestData = try
            JSONFileEncoder.shared.encode(newProjectManifest)
        
        try newProjectManifestData.write(to: projectManifestURL)
        
        // Find assets referenced in the old manifest but not the
        // new one. Move these to the new history entry
        let diffAssetIDs = oldAssetIDs.subtracting(newAssetIDs)
        
        for diffAssetID in diffAssetIDs {
            try moveAssetInProjectToEditHistoryEntry(
                assetID: diffAssetID,
                entryURL: entryURL)
        }
        
        // Update state
        self.projectManifest = newProjectManifest
        updateAvailableUndoRedoCount()
    }
    
    private func consumeHistoryEntryInternal(undo: Bool) throws {
        let consumedEntryContainingDirectoryURL = undo ?
            undoHistoryDirectoryURL() :
            redoHistoryDirectoryURL()
        
        let createdEntryContainingDirectoryURL = undo ?
            redoHistoryDirectoryURL() :
            undoHistoryDirectoryURL()
        
        guard let consumedHistoryEntryURL = firstEditHistoryEntryURL(
            in: consumedEntryContainingDirectoryURL)
        else { return }
        
        // Setup
        let currentProjectManifest = self.projectManifest
        
        let projectURL = FileHelper.shared.projectURL(for: projectID)
        
        let projectManifestURL = FileHelper.shared
            .projectManifestURL(for: projectID)
        
        let consumedProjectManifestURL = consumedHistoryEntryURL
            .appending(path: FileHelper.projectManifestFileName)
        
        let consumedProjectManifestData = try Data(
            contentsOf: consumedProjectManifestURL)
        
        let consumedProjectManifest = try JSONFileDecoder.shared.decode(
            Project.Manifest.self,
            from: consumedProjectManifestData)
        
        // Create new history entry
        let createdHistoryEntryURL = try pushNewEditHistoryEntry(
            in: createdEntryContainingDirectoryURL)
        
        // Copy current project manifest to new history entry
        let createdHistoryEntryProjectManifestURL = createdHistoryEntryURL
            .appending(path: FileHelper.projectManifestFileName)
        
        try fileManager.copyItem(
            at: projectManifestURL,
            to: createdHistoryEntryProjectManifestURL)
        
        // Move asset files from consumed entry to project
        let consumedEntryFileURLs = try fileManager.contentsOfDirectory(
            at: consumedHistoryEntryURL,
            includingPropertiesForKeys: nil)
            
        for fileURL in consumedEntryFileURLs {
            let fileName = fileURL.lastPathComponent
            if fileName == FileHelper.projectManifestFileName { continue }
            
            let destinationURL = projectURL
                .appendingPathComponent(fileName)
            
            try fileManager.moveItem(at: fileURL, to: destinationURL)
        }
        
        // Replace project manifest with consumed entry manifest
        let consumedEntryProjectManifestURL =
            consumedHistoryEntryURL.appending(
                path: FileHelper.projectManifestFileName)
        
        _ = try fileManager.replaceItemAt(
            projectManifestURL,
            withItemAt: consumedEntryProjectManifestURL)
        
        // Delete the consumed history entry
        try popFirstEditHistoryEntry(
            in: consumedEntryContainingDirectoryURL)
        
        // Find assets referenced in the old manifest but not the
        // new one. Move these to the new history entry directory
        let oldAssetIDs = Self.allAssetIDs(in: currentProjectManifest)
        let newAssetIDs = Self.allAssetIDs(in: consumedProjectManifest)
        
        let diffAssetIDs = oldAssetIDs.subtracting(newAssetIDs)
        
        for diffAssetID in diffAssetIDs {
            try moveAssetInProjectToEditHistoryEntry(
                assetID: diffAssetID,
                entryURL: createdHistoryEntryURL)
        }
        
        // Update state
        self.projectManifest = consumedProjectManifest
        updateAvailableUndoRedoCount()
    }
    
    // MARK: - Interface
    
    func applyEdit(
        newProjectManifest: Project.Manifest,
        newAssets: [NewAsset]
    ) {
        workQueue.enqueueTask {
            try self.applyEditInternal(
                newProjectManifest: newProjectManifest,
                newAssets: newAssets)
        }
    }
    
    func applyUndo() {
        workQueue.enqueueTask {
            try self.consumeHistoryEntryInternal(
                undo: true)
        }
    }
    
    func applyRedo() {
        workQueue.enqueueTask {
            try self.consumeHistoryEntryInternal(
                undo: false)
        }
    }
    
    func waitForAllTasksToComplete() {
        workQueue.waitForAllTasksToComplete()
    }
    
}
