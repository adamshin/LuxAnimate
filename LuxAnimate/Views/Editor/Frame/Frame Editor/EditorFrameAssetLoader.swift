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
        case small
        case medium
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
    
    private var preCachedFullTextures: [String: MTLTexture] = [:]
    
    private let fileUrlHelper = FileUrlHelper()
    
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
        
        drawingIDsToLoad = Set(allDrawings.map { $0.id })
        
        // Roll over any precached or already-loaded
        // assets that we can reuse
        let oldLoadedAssets = loadedAssets
        loadedAssets = [:]
        
        for drawing in allDrawings {
            if let texture = preCachedFullTextures[drawing.id] {
                loadedAssets[drawing.id] = LoadedAsset(
                    fullAssetID: drawing.assetIDs.full,
                    quality: .full,
                    texture: texture)
                
            } else if let existingAsset = oldLoadedAssets[drawing.id],
                existingAsset.fullAssetID == drawing.assetIDs.full
            {
                loadedAssets[drawing.id] = existingAsset
            }
        }
        
        preCachedFullTextures = [:]
        
        // Create load items
        var loadItems: [LoadItem] = []
        
        for drawing in nonActiveDrawings {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .medium))
        }
        
        if let drawing = activeDrawing {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                assetIDs: drawing.assetIDs,
                quality: .medium))
            
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
                self.processNextPendingLoadItem()
            }
        }
    }
    
    private func processNextPendingLoadItem() {
        while let item = pendingLoadItems.first {
            pendingLoadItems.removeFirst()
            
            let drawingID = item.drawingID
            if !drawingIDsToLoad.contains(drawingID) {
                continue
            }
            
            if let existingAsset = loadedAssets[drawingID],
               existingAsset.fullAssetID == item.assetIDs.full,
               existingAsset.quality.rawValue >= item.quality.rawValue
            {
                delegate?.onUpdateProgress(self)
                continue
            }
            
            let assetID = switch item.quality {
            case .small: item.assetIDs.small
            case .medium: item.assetIDs.medium
            case .full: item.assetIDs.full
            }
            let assetURL = fileUrlHelper.projectAssetURL(
                projectID: projectID,
                assetID: assetID)
            
            loadQueue.async {
                do {
                    let encodedData = try Data(contentsOf: assetURL)
                    
                    guard self.drawingIDsToLoad.contains(drawingID) else {
                        DispatchQueue.main.async {
                            self.processNextPendingLoadItem()
                        }
                        return
                    }
                    
                    let output = try JXLDecoder.decode(
                        data: encodedData,
                        progress: {
                            self.drawingIDsToLoad.contains(drawingID)
                        })
                    
                    let texture = try TextureCreator.createTexture(
                        imageData: output.data,
                        width: output.width,
                        height: output.height,
                        mipMapped: false,
                        usage: .shaderRead)
                    
                    let asset = LoadedAsset(
                        fullAssetID: item.assetIDs.full,
                        quality: item.quality,
                        texture: texture)
                    
                    DispatchQueue.main.async {
                        if self.drawingIDsToLoad.contains(item.drawingID) {
                            self.loadedAssets[item.drawingID] = asset
                            self.delegate?.onUpdateProgress(self)
                        }
                        self.processNextPendingLoadItem()
                    }
                    
                } catch {
                    DispatchQueue.main.async {
                        self.processNextPendingLoadItem()
                    }
                }
            }
            return
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
    
    func asset(for drawingID: String) -> LoadedAsset? {
        loadedAssets[drawingID]
    }
    
    func hasAssetsForAllDrawings() -> Bool {
        !drawingIDsToLoad.contains {
            loadedAssets[$0] == nil
        }
    }
    
    func preCacheFullTexture(
        texture: MTLTexture,
        drawingID: String
    ) {
        do {
            let newTexture = try TextureCopier.copy(texture)
            preCachedFullTextures[drawingID] = newTexture
            
        } catch { }
    }
    
}
