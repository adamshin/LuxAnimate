//
//  EditorUndoHistoryManager.swift
//

import Foundation

struct EditorUndoHistoryManager {
    
    let projectID: String
    
    private let fileManager = FileManager.default
    private let fileUrlHelper = FileUrlHelper()
    
    func beginSession() throws {
        try removeProjectUndoHistoryDirectory()
        try createProjectUndoHistoryDirectory()
    }
    
    func endSession() throws {
        try removeProjectUndoHistoryDirectory()
    }
    
    private func projectUndoHistoryDirectoryURL() -> URL {
        fileUrlHelper
            .projectCacheDirectoryURL(for: projectID)
            .appending(path: "undohistory")
    }
    
    private func removeProjectUndoHistoryDirectory() throws {
        let url = projectUndoHistoryDirectoryURL()
        try fileManager.removeItem(at: url)
    }
    
    private func createProjectUndoHistoryDirectory() throws {
        let url = projectUndoHistoryDirectoryURL()
        
        if fileManager.fileExists(atPath: url.path()) {
            return
        }
        try fileManager.createDirectory(
            at: url,
            withIntermediateDirectories: true)
    }
    
}
