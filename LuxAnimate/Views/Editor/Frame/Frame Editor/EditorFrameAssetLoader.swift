//
//  EditorFrameAssetLoader.swift
//

import Foundation
import Metal

protocol EditorFrameAssetLoaderDelegate: AnyObject {
    
    func onUpdateProgress(_ loader: EditorFrameAssetLoader)
    
}

class EditorFrameAssetLoader {
    
    enum AssetQuality: Int {
        case preview
        case full
    }
    
    struct LoadItem {
        var drawingID: String
        var assetIDs: Project.DrawingAssetIDGroup
        var quality: AssetQuality
    }
    
    struct LoadedAsset {
        var fullAssetID: String
        var quality: AssetQuality
        var texture: MTLTexture
    }
    
    weak var delegate: EditorFrameAssetLoaderDelegate?
    
    private let projectID: String
    
    private var pendingLoadItems: [LoadItem] = []
    private var loadedAssets: [String: LoadedAsset] = [:]
    
    private let fileUrlHelper = FileUrlHelper()
    private let textureCopier = TextureCopier()
    
    private let syncQueue = DispatchQueue(
        label: "EditorFrameAssetLoader.syncQueue",
        qos: .default)
    
    private let loadQueue = DispatchQueue(
        label: "EditorFrameAssetLoader.loadQueue",
        qos: .background)
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Loading
    
    private func loadAssetsInternal(
        drawings: [Project.Drawing],
        activeDrawingID: String?
    ) {
        // Create list of drawings to load
        var allDrawings: [Project.Drawing] = []
        var activeDrawing: Project.Drawing? = nil
        var nonActiveDrawings: [Project.Drawing] = []
        
        for drawing in drawings {
            allDrawings.append(drawing)
            if drawing.id == activeDrawingID {
                activeDrawing = drawing
            } else {
                nonActiveDrawings.append(drawing)
            }
        }
        
        // Roll over any already-loaded assets that we can reuse
        let oldLoadedAssets = loadedAssets
        loadedAssets = [:]
        
        for drawing in allDrawings {
            if let existingAsset = oldLoadedAssets[drawing.id],
                existingAsset.fullAssetID == drawing.assetIDs.full
            {
                loadedAssets[drawing.id] = existingAsset
            }
        }
        
        // Create load items
        pendingLoadItems = []
        
        for drawing in nonActiveDrawings {
            pendingLoadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .preview))
        }
        
        if let drawing = activeDrawing {
            pendingLoadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .preview))
            
            pendingLoadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .full))
        }
        
        for drawing in nonActiveDrawings {
            pendingLoadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .full))
        }
        
        processNextPendingLoadItem()
    }
    
    private func processNextPendingLoadItem() {
        syncQueue.async {
            self.processNextPendingLoadItemInternal()
        }
    }
    
    private func processNextPendingLoadItemInternal() {
        guard let item = pendingLoadItems.first
        else { return }
        
        pendingLoadItems.removeFirst()
        
        if let existingAsset = loadedAssets[item.drawingID],
            existingAsset.fullAssetID == item.assetIDs.full,
            existingAsset.quality.rawValue >= item.quality.rawValue
        {
            DispatchQueue.main.async {
                self.delegate?.onUpdateProgress(self)
            }
            processNextPendingLoadItem()
            return
        }
        
        let assetID = switch item.quality {
        case .preview: item.assetIDs.medium
        case .full: item.assetIDs.full
        }
        let assetURL = fileUrlHelper.projectAssetURL(
            projectID: projectID,
            assetID: assetID)
        
        loadQueue.async {
            do {
                let texture = try JXLTextureLoader.load(url: assetURL)
                
                let asset = LoadedAsset(
                    fullAssetID: item.assetIDs.full,
                    quality: item.quality,
                    texture: texture)
                
                self.syncQueue.async {
                    self.loadedAssets[item.drawingID] = asset
                    self.processNextPendingLoadItem()
                    
                    DispatchQueue.main.async {
                        self.delegate?.onUpdateProgress(self)
                    }
                }
                
            } catch {
                self.processNextPendingLoadItem()
            }
        }
    }
    
    // MARK: - Interface
    
    func loadAssets(
        drawings: [Project.Drawing],
        activeDrawingID: String?
    ) {
        syncQueue.async {
            self.loadAssetsInternal(
                drawings: drawings,
                activeDrawingID: activeDrawingID)
        }
    }
    
    func hasLoadedAllPendingAssets() -> Bool {
        pendingLoadItems.count == 0
    }
    
    func asset(for drawingID: String) -> LoadedAsset? {
        loadedAssets[drawingID]
    }
    
    func cacheFullTexture(
        texture: MTLTexture,
        drawingID: String,
        fullAssetID: String
    ) {
        do {
            let newTexture = try textureCopier.copy(texture)
            
            syncQueue.async {
                self.loadedAssets[drawingID] = LoadedAsset(
                    fullAssetID: fullAssetID,
                    quality: .full,
                    texture: newTexture)
            }
            
        } catch { }
    }
    
}
