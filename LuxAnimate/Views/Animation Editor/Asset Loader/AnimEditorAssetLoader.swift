//
//  AnimEditorAssetLoader.swift
//

import Metal

private let maxConcurrentOperations = 3

extension AnimEditorAssetLoader {
    
    @MainActor
    protocol Delegate: AnyObject, Sendable {
        
        func pendingAssetData(
            _ l: AnimEditorAssetLoader,
            assetID: String
        ) -> Data?
        
        func onUpdate(_ l: AnimEditorAssetLoader)
        func onFinish(_ l: AnimEditorAssetLoader)
        
    }
    
    enum LoadedAsset: @unchecked Sendable {
        case loaded(MTLTexture)
        case error
        
        var texture: MTLTexture? {
            switch self {
            case .loaded(let texture): texture
            case .error: nil
            }
        }
    }
    
}

@MainActor
class AnimEditorAssetLoader {
    
    private let projectID: String
    
    private let limitedConcurrencyQueue =
        LimitedConcurrencyQueue(
            maxConcurrentOperations: maxConcurrentOperations)
    
    private var assetIDs: Set<String> = []
    private var inProgressTasks: [String: Task<Void, Error>] = [:]
    private var loadedAssets: [String: LoadedAsset] = [:]
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(
        projectID: String
    ) {
        self.projectID = projectID
    }
    
    // MARK: - Interface
    
    func update(assetIDs: Set<String>) {
        self.assetIDs = assetIDs
        
        loadedAssets = loadedAssets.filter {
            assetIDs.contains($0.key)
        }
        
        for (assetID, task) in inProgressTasks {
            if !assetIDs.contains(assetID) {
                task.cancel()
                inProgressTasks[assetID] = nil
            }
        }
        
        let assetIDsToLoad = assetIDs
            .subtracting(Set(inProgressTasks.keys))
            .subtracting(Set(loadedAssets.keys))
        
        for assetID in assetIDsToLoad {
            let task = Task.detached(priority: .high) {
                try await self.limitedConcurrencyQueue.enqueue {
                    try await self.loadAsset(assetID: assetID)
                }
            }
            inProgressTasks[assetID] = task
        }
        
        if inProgressTasks.isEmpty {
            delegate?.onFinish(self)
        }
    }
    
    func loadedAsset(assetID: String) -> LoadedAsset? {
        loadedAssets[assetID]
    }
    
    // MARK: - Internal Methods
    
    private func storeLoadedAsset(
        assetID: String,
        loadedAsset: LoadedAsset
    ) {
        inProgressTasks[assetID] = nil
        
        guard assetIDs.contains(assetID)
        else { return }
        
        loadedAssets[assetID] = loadedAsset
        
        delegate?.onUpdate(self)
        if inProgressTasks.isEmpty {
            delegate?.onFinish(self)
        }
    }
    
    nonisolated private func loadAsset(
        assetID: String
    ) async throws {
        do {
            let assetData: Data
            if let pendingAssetData = await delegate?
                .pendingAssetData(self, assetID: assetID)
            {
                assetData = pendingAssetData
                
            } else {
                let assetURL = FileHelper.shared
                    .projectAssetURL(
                        projectID: projectID,
                        assetID: assetID)
                
                assetData = try Data(contentsOf: assetURL)
            }
            
            try Task.checkCancellation()
            
            let decoderOutput = try await JXLDecoder
                .decodeAsync(data: assetData)
            
            let texture = try TextureCreator.createTexture(
                pixelData: decoderOutput.pixelData,
                size: PixelSize(
                    width: decoderOutput.width,
                    height: decoderOutput.height),
                mipMapped: false,
                usage: .shaderRead)
            
            await self.storeLoadedAsset(
                assetID: assetID,
                loadedAsset: .loaded(texture))
            
        } catch is CancellationError {
            
        } catch {
            await storeLoadedAsset(
                assetID: assetID,
                loadedAsset: .error)
        }
    }
    
}
