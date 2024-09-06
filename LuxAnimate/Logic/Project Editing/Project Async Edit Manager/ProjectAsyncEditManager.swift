//
//  ProjectAsyncEditManager.swift
//

import Foundation

protocol ProjectAsyncEditManagerDelegate: AnyObject {
    
    func onUpdateState(_ m: ProjectAsyncEditManager)
    
    func onError(
        _ m: ProjectAsyncEditManager,
        error: Error)
    
}

class ProjectAsyncEditManager {
    
    private let projectID: String
    
    private let editManager: ProjectEditManager
    
    private let workQueue = DispatchQueue(
        label: "ProjectAsyncEditManager.queue",
        qos: .userInitiated)
    
    private let pendingEditAssetStore =
        ProjectAsyncEditManagerPendingEditAssetStore()
    
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
    
    private func applyEditInternal(
        edit: ProjectEditManager.Edit
    ) {
        projectManifest = edit.projectManifest
        
        availableRedoCount = 0
        availableUndoCount = min(
            availableUndoCount + 1,
            ProjectEditManager.editHistoryLimit)
        
        pendingEditAssetStore.storeAssets(edit.newAssets)
        
        delegate?.onUpdateState(self)
        
        workQueue.async {
            do {
                try self.editManager.applyEdit(edit)
            } catch { 
                DispatchQueue.main.async {
                    self.delegate?.onError(self, error: error)
                }
            }
            
            let newAssetIDs = edit.newAssets.map { $0.id }
            self.pendingEditAssetStore.removeAssets(
                assetIDs: newAssetIDs)
        }
    }
    
    private func applyUndoRedoInternal(
        undo: Bool
    ) {
        workQueue.async {
            do {
                if undo {
                    try self.editManager.applyUndo()
                } else {
                    try self.editManager.applyRedo()
                }
                
                DispatchQueue.main.async {
                    self.projectManifest = self.editManager.projectManifest
                    self.availableUndoCount = self.editManager.availableUndoCount
                    self.availableRedoCount = self.editManager.availableRedoCount
                    
                    self.delegate?.onUpdateState(self)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.onError(self, error: error)
                }
            }
        }
    }
    
    // MARK: - Interface
    
    func applyEdit(
        edit: ProjectEditManager.Edit
    ) {
        applyEditInternal(edit: edit)
    }
    
    func applyUndo() {
        applyUndoRedoInternal(undo: true)
    }
    
    func applyRedo() {
        applyUndoRedoInternal(undo: false)
    }
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        
        pendingEditAssetStore.storedAsset(
            assetID: assetID)
    }
    
}

// MARK: - Pending Edit Asset Store

class ProjectAsyncEditManagerPendingEditAssetStore {
    
    private var storedAssets = ThreadSafeDictionary
        <String, ProjectEditManager.NewAsset>()
    
    func storeAssets(
        _ assets: [ProjectEditManager.NewAsset]
    ) {
        let values = Dictionary(
            assets.map { ($0.id, $0) },
            uniquingKeysWith: { $1 })
        
        storedAssets.setValues(values)
    }
    
    func removeAssets(
        assetIDs: [String]
    ) {
        storedAssets.removeValues(forKeys: assetIDs)
    }
    
    func storedAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        return storedAssets.getValue(forKey: assetID)
    }
    
}
