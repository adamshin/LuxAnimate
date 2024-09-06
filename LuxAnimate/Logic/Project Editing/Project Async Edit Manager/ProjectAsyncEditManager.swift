//
//  ProjectAsyncEditManager.swift
//

import Foundation

protocol ProjectAsyncEditManagerDelegate: AnyObject {
    
    func onCompleteUndoRedo(_ m: ProjectAsyncEditManager)
    
}

class ProjectAsyncEditManager {
    
    private let projectID: String
    
    private let editManager: ProjectEditManager
    
    private let workQueue = DispatchQueue(
        label: "ProjectAsyncEditManager.queue",
        qos: .userInitiated)
    
    private(set) var projectManifest: Project.Manifest
    
    private(set) var availableUndoCount: Int
    private(set) var availableRedoCount: Int
    
    weak var delegate: ProjectAsyncEditManagerDelegate?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editManager = try ProjectEditManager(
            projectID: projectID)
        
        projectManifest = editManager.projectManifest
        availableUndoCount = editManager.availableUndoCount
        availableRedoCount = editManager.availableRedoCount
    }
    
    // MARK: - Internal Logic
    
    private func applyUndoSync() throws {
        try editManager.applyUndo()
        
        projectManifest = editManager.projectManifest
        availableUndoCount = editManager.availableUndoCount
        availableRedoCount = editManager.availableRedoCount
        
        delegate?.onCompleteUndoRedo(self)
    }
    
    private func applyRedoSync() throws {
        try editManager.applyRedo()
        
        projectManifest = editManager.projectManifest
        availableUndoCount = editManager.availableUndoCount
        availableRedoCount = editManager.availableRedoCount
        
        delegate?.onCompleteUndoRedo(self)
    }
    
    // MARK: - Interface
    
    func applyUndo() {
        workQueue.async {
            do {
                try self.applyUndoSync()
            } catch { }
        }
    }
    
    func applyRedo() {
        workQueue.async {
            do {
                try self.applyRedoSync()
            } catch { }
        }
    }
    
    func applyEdit(
        edit: ProjectEditManager.Edit
    ) {
        // TODO: Update local state immediately.
        // Project manifest, undo/redo count
        
        workQueue.async {
            do {
                try self.editManager.applyEdit(edit)
            } catch { }
        }
    }
    
    // These methods won't actually work here. Will they?
    // We have to have an updated project manifest. Here,
    // that doesn't get created until internally in the
    // project edit manager.
    
    /*
    func createScene(
        name: String,
        frameCount: Int,
        backgroundColor: Color
    ) {
        try! editManager.createScene(
            name: name,
            frameCount: frameCount,
            backgroundColor: backgroundColor)
    }
    
    func deleteScene(
        sceneID: String
    ) {
        try! editManager.deleteScene(
            sceneID: sceneID)
    }
    
    func applySceneEdit(
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset]
    ) {
        try! editManager.applySceneEdit(
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: newSceneAssets)
    }
     */
    
}
