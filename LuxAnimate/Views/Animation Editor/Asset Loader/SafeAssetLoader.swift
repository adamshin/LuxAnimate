//
//  SafeAssetLoader.swift
//

import Metal

extension SafeAssetLoader {
    
    @MainActor
    protocol Delegate: AnyObject, Sendable {
        
        func pendingAssetData(
            _ l: SafeAssetLoader,
            assetID: String
        ) async -> Data?
        
        func onUpdate(_ l: SafeAssetLoader)
        func onFinish(_ l: SafeAssetLoader)
        
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
class SafeAssetLoader {
    
    private let projectID: String
    
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
                try await self.loadAsset(assetID: assetID)
            }
            inProgressTasks[assetID] = task
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
            await Task.yield()
            
            let texture = try await decodeTexture(
                assetID: assetID,
                assetData: assetData)
            
            await storeLoadedAsset(
                assetID: assetID,
                loadedAsset: .loaded(texture))
            
        } catch is CancellationError {
            
        } catch {
            await storeLoadedAsset(
                assetID: assetID,
                loadedAsset: .error)
        }
    }
    
    nonisolated private func decodeTexture(
        assetID: String,
        assetData: Data
    ) async throws -> MTLTexture {
        
        let output = try await JXLDecoder.decodeAsync(
            data: assetData)
        
        let texture = try TextureCreator.createTexture(
            pixelData: output.pixelData,
            size: PixelSize(
                width: output.width,
                height: output.height),
            mipMapped: false,
            usage: .shaderRead)
        
        try Task.checkCancellation()
        await Task.yield()
        
        return texture
    }
    
}
