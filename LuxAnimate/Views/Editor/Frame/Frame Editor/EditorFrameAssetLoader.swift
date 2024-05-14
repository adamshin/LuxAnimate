//
//  EditorFrameAssetLoader.swift
//

import Foundation
import Metal

// TODO: Add flag to load item, saying whether to
// notify delegate after load completes? Might be
// the best way to have control over when to draw.

// TODO: Replace recursion with loop when skipping
// items. Don't want a stack overflow

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
    
    private var drawingIDsToLoad: Set<String> = []
    private var pendingLoadItems: [LoadItem] = []
    private var loadedAssets: [String: LoadedAsset] = [:]
    
    private let fileUrlHelper = FileUrlHelper()
    private let textureCopier = TextureCopier()
    
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
        print("Loading assets")
        
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
        
        drawingIDsToLoad = Set(allDrawings.map { $0.id })
        
        // Roll over any already-loaded assets that we can reuse
        print("Previous loaded asset count: \(loadedAssets.count)")
        let oldLoadedAssets = loadedAssets
        loadedAssets = [:]
        
        for drawing in allDrawings {
            if let existingAsset = oldLoadedAssets[drawing.id],
                existingAsset.fullAssetID == drawing.assetIDs.full
            {
                loadedAssets[drawing.id] = existingAsset
            }
        }
        
        print("Reusing assets: \(loadedAssets.count)")
        
        // Create load items
        var loadItems: [LoadItem] = []
        
        for drawing in nonActiveDrawings {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .preview))
        }
        
        if let drawing = activeDrawing {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .preview))
            
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .full))
        }
        
        for drawing in nonActiveDrawings {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .full))
        }
        
        // Queue up work. Wait for any pending load items
        // to finish first
        loadQueue.async {
            DispatchQueue.main.async {
                self.pendingLoadItems = loadItems
                print("Pending items: \(self.pendingLoadItems.count)")
                self.processNextPendingLoadItem()
            }
        }
    }
    
    private func processNextPendingLoadItem() {
        print("Processing next pending item. Pending count: \(pendingLoadItems.count), loaded asset count: \(loadedAssets.count)")
        
        guard let item = pendingLoadItems.first
        else { return }
        
        pendingLoadItems.removeFirst()
        
        if let existingAsset = loadedAssets[item.drawingID],
            existingAsset.fullAssetID == item.assetIDs.full,
            existingAsset.quality.rawValue >= item.quality.rawValue
        {
            print("Skipping load item, already cached")
            delegate?.onUpdateProgress(self)
            processNextPendingLoadItem() // recursion - stack overflow?
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
                
                DispatchQueue.main.async {
                    print("Loaded asset")
                    
                    if self.drawingIDsToLoad.contains(item.drawingID) {
                        self.loadedAssets[item.drawingID] = asset
                        self.delegate?.onUpdateProgress(self)
                    } else {
                        print("Asset no longer needed - discarding")
                    }
                    
                    self.processNextPendingLoadItem()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.processNextPendingLoadItem()
                }
            }
        }
    }
    
    // MARK: - Interface
    
    func loadAssets(
        drawings: [Project.Drawing],
        activeDrawingID: String?
    ) {
        loadAssetsInternal(
            drawings: drawings,
            activeDrawingID: activeDrawingID)
    }
    
    func hasPendingPreviewLoadItems() -> Bool {
        pendingLoadItems.contains {
            $0.quality == .preview
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
            
            loadedAssets[drawingID] = LoadedAsset(
                fullAssetID: fullAssetID,
                quality: .full,
                texture: newTexture)
            
        } catch { }
    }
    
}
