//
//  EditorSessionManager.swift
//

import Foundation

struct EditorSessionManager {
    
    private let projectID: String
    
    private let projectManifestReader = ProjectManifestReader()
    
    private let undoHistoryManager: EditorUndoHistoryManager
    
    init(projectID: String) {
        self.projectID = projectID
        
        undoHistoryManager = EditorUndoHistoryManager(projectID: projectID)
    }
    
    func beginSession() throws -> ProjectManifest {
        let projectManifest = try projectManifestReader
            .getProjectManifest(for: projectID)
        
        try undoHistoryManager.beginSession()
        
        return projectManifest
    }
    
    func endSession() throws {
        try undoHistoryManager.endSession()
    }
    
    // TODO: Figure out how file writing and undo history are connected.
    // Maybe they need to live under the same roof. Writing an update to the
    // project directory is intimately linked to generating the undo diff.
    
}
