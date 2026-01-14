//
//  ProjectAsyncEditManager.swift
//

import Foundation

extension ProjectAsyncEditManager {
    
    protocol Delegate: AnyObject {
        
        func onUpdateState(
            _ m: ProjectAsyncEditManager)
        
        func onEditError(
            _ m: ProjectAsyncEditManager,
            error: Error)
        
    }
    
}

class ProjectAsyncEditManager {
    
    private let projectID: String
    
    private let editManager: ProjectEditManager
    
    private let workQueue = DispatchQueue(
        label: "ProjectAsyncEditManager.workQueue",
        qos: .userInitiated)
    
    private(set) var projectManifest: Project.Manifest
    private(set) var availableUndoCount: Int
    private(set) var availableRedoCount: Int
    
    private var pendingEditAssets:
        [String: ProjectEditManager.NewAsset] = [:]
    
    weak var delegate: Delegate?
    
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
        // Update state
        projectManifest = edit.projectManifest
        
        availableRedoCount = 0
        availableUndoCount = min(
            self.availableUndoCount + 1,
            ProjectEditManager.editHistoryLimit)
        
        // Store pending assets
        storePendingEditAssets(edit.newAssets)
        
        // Notify delegate
        delegate?.onUpdateState(self)
        
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
                self.removePendingEditAssets(
                    assetIDs: newAssetIDs)
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
                    self.projectManifest =
                        self.editManager.projectManifest
                    self.availableUndoCount =
                        self.editManager.availableUndoCount
                    self.availableRedoCount =
                        self.editManager.availableRedoCount
                    
                    self.delegate?.onUpdateState(self)
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
    
    func pendingEditAsset(assetID: String)
    -> ProjectEditManager.NewAsset? {
        pendingEditAssets[assetID]
    }
    
}
