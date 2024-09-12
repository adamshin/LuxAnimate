//
//  ProjectAsyncEditManager.swift
//

import Foundation

protocol ProjectAsyncEditManagerDelegate: AnyObject {
    
    func onUpdateState(
        _ m: ProjectAsyncEditManager,
        editContext: Sendable?)
    
    func onError(
        _ m: ProjectAsyncEditManager,
        error: Error)
    
}

class ProjectAsyncEditManager: @unchecked Sendable {
    
    private let projectID: String
    
    private let editManager: ProjectEditManager
    
    private let workQueue = DispatchQueue(
        label: "ProjectAsyncEditManager.queue",
        qos: .userInitiated)
    
    private let pendingEditAssetStore =
        ProjectAsyncEditManagerPendingEditAssetStore()
    
    private(set) var state: ProjectEditManager.State
    
    weak var delegate: ProjectAsyncEditManagerDelegate?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editManager = try ProjectEditManager(
            projectID: projectID)
        
        state = editManager.state
    }
    
    // MARK: - Internal Logic
    
    private func applyEditInternal(
        edit: ProjectEditManager.Edit,
        editContext: Sendable?
    ) {
        // Update state
        state.projectManifest = edit.projectManifest
        
        state.availableRedoCount = 0
        state.availableUndoCount = min(
            state.availableUndoCount + 1,
            ProjectEditManager.editHistoryLimit)
        
        // Store pending assets
        pendingEditAssetStore.storeAssets(edit.newAssets)
        
        // Notify delegate
        delegate?.onUpdateState(self, editContext: editContext)
        
        // Perform edit
        workQueue.async {
            do {
                try self.editManager.applyEdit(edit)
            } catch { 
                DispatchQueue.main.async {
                    self.delegate?.onError(self, error: error)
                }
            }
            
            // Remove pending assets
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
                    self.state = self.editManager.state
                    
                    self.delegate?.onUpdateState(
                        self, editContext: nil)
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
        edit: ProjectEditManager.Edit,
        editContext: Sendable?
    ) {
        applyEditInternal(
            edit: edit,
            editContext: editContext)
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
