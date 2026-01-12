//
//  ProjectAsyncEditManager.swift
//

import Foundation

extension ProjectAsyncEditManager {
    
    protocol Delegate: AnyObject {
        
        func onUpdateState(
            _ m: ProjectAsyncEditManager,
            state: ProjectEditManager.State)
        
        func onEditError(
            _ m: ProjectAsyncEditManager,
            error: Error)
        
    }
    
}

class ProjectAsyncEditManager: @unchecked Sendable {
    
    private let projectID: String
    
    private let editManager: ProjectEditManager
    
    private let workQueue = DispatchQueue(
        label: "ProjectAsyncEditManager.queue",
        qos: .userInitiated)
    
    private(set) var state: ProjectEditManager.State
    
    private var pendingEditAssets:
        [String: ProjectEditManager.NewAsset] = [:]
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editManager = try ProjectEditManager(
            projectID: projectID)
        
        state = editManager.state
    }
    
    // MARK: - Internal Logic
    
    private func applyEditInternal(
        edit: ProjectEditManager.Edit
    ) {
        // Update state
        state.projectManifest = edit.projectManifest
        
        state.availableRedoCount = 0
        state.availableUndoCount = min(
            state.availableUndoCount + 1,
            ProjectEditManager.editHistoryLimit)
        
        // Store pending assets
        storePendingEditAssets(edit.newAssets)
        
        // Notify delegate
        delegate?.onUpdateState(self, state: state)
        
        // Perform edit
        workQueue.async {
            do {
                try self.editManager.applyEdit(edit)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.onEditError(
                        self, error: error)
                }
            }
            
            // Remove pending assets
            let newAssetIDs = edit.newAssets.map { $0.id }
            DispatchQueue.main.async {
                self.removePendingEditAssets(assetIDs: newAssetIDs)
            }
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
                        self, state: self.state)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.onEditError(
                        self, error: error)
                }
            }
        }
    }
    
    private func storePendingEditAssets(
        _ assets: [ProjectEditManager.NewAsset]
    ) {
        for asset in assets {
            pendingEditAssets[asset.id] = asset
        }
    }
    
    private func removePendingEditAssets(
        assetIDs: [String]
    ) {
        for assetID in assetIDs {
            pendingEditAssets[assetID] = nil
        }
    }
    
    // MARK: - Interface
    
    func applyEdit(edit: ProjectEditManager.Edit) {
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
        pendingEditAssets[assetID]
    }
    
}
