//
//  AnimationFrameEditorAssetLoader.swift
//

import Foundation
import Metal

protocol AnimationFrameEditorAssetLoaderDelegate: AnyObject {
    func onFinishLoading(_ loader: AnimationFrameEditorAssetLoader)
}

class AnimationFrameEditorAssetLoader {
    
    struct LoadItem {
        var drawingID: String
        var fullAssetID: String?
    }
    
    struct LoadedAsset {
        var texture: MTLTexture?
    }
    
    private struct SkipLoadError: Error { }
    
    weak var delegate: AnimationFrameEditorAssetLoaderDelegate?
    
    private let projectID: String
    
    private var pendingLoadItems: [LoadItem] = []
    private var loadedAssets: [String: LoadedAsset] = [:]
    
    private var isCancelled = false
    
    private let loadQueue = DispatchQueue(
        label: "AnimationFrameEditorAssetLoader.loadQueue",
        qos: .background)
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Loading
    
    func loadAssets(drawings: [Scene.Drawing]) {
        // TODO: Reuse previously loaded assets?
        var loadItems: [LoadItem] = []
        
        for drawing in drawings {
            loadItems.append(LoadItem(
                drawingID: drawing.id,
                fullAssetID: drawing.assetIDs?.full))
        }
        
        loadQueue.async {
            DispatchQueue.main.async {
                self.pendingLoadItems = loadItems
                self.processNextPendingLoadItem()
            }
        }
    }
    
    func cancelLoadingAssets() {
        isCancelled = true
    }
    
    private func processNextPendingLoadItem() {
        // Check this logic?
        // TODO: Update delegate when all items are loaded
        while let item = pendingLoadItems.first {
            pendingLoadItems.removeFirst()
            
            let drawingID = item.drawingID
            
            guard let fullAssetID = item.fullAssetID else {
                continue
            }
            
            let assetURL = FileHelper.shared.projectAssetURL(
                projectID: projectID,
                assetID: fullAssetID)
            
            loadQueue.async {
                do {
                    guard !self.isCancelled else { throw SkipLoadError() }
                    let encodedData = try Data(contentsOf: assetURL)
                    
                    guard !self.isCancelled else { throw SkipLoadError() }
                    let output = try JXLDecoder.decode(
                        data: encodedData,
                        progress: { !self.isCancelled })
                    
                    let texture = try TextureCreator.createTexture(
                        imageData: output.data,
                        size: PixelSize(
                            width: output.width,
                            height: output.height),
                        mipMapped: false,
                        usage: .shaderRead)
                    
                    let asset = LoadedAsset(texture: texture)
                    
                    DispatchQueue.main.async {
                        self.loadedAssets[item.drawingID] = asset
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
    
    func asset(for drawingID: String) -> LoadedAsset? {
        loadedAssets[drawingID]
    }
    
}
