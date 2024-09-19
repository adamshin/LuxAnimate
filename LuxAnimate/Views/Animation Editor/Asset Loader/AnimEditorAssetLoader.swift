//
//  AnimEditorAssetLoader.swift
//

import Metal
import MetalKit

extension AnimEditorAssetLoader {
    
    @MainActor
    protocol Delegate: AnyObject, Sendable {
        
        func pendingAssetData(
            _ l: AnimEditorAssetLoader,
            assetID: String
        ) -> Data?
        
        func onUpdate(_ l: AnimEditorAssetLoader)
        
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
    
    private let updateLimiter = ConcurrencyLimiter(limit: 1)
    
    private var assetIDs: Set<String> = []
    private var inProgressTasks: [String: Task<Void, Error>] = [:]
    
    private(set) var loadedAssets: [String: LoadedAsset] = [:]
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Interface
    
    func update(assetIDs: Set<String>) {
        Task.detached(priority: .userInitiated) {
            try await self.updateLimiter.run {
                await self.updateInternal(assetIDs: assetIDs)
            }
        }
    }
    
    // MARK: - Internal Methods
    
    private func updateInternal(
        assetIDs: Set<String>
    ) async {
        self.assetIDs = assetIDs
        
        loadedAssets = loadedAssets.filter {
            assetIDs.contains($0.key)
        }
        
        var cancelledTasks: [Task<Void, Error>] = []
        
        for (assetID, task) in inProgressTasks {
            if !assetIDs.contains(assetID) {
                task.cancel()
                inProgressTasks[assetID] = nil
                cancelledTasks.append(task)
            }
        }
        
        for task in cancelledTasks {
            _ = await task.result
        }
        
        let assetIDsToLoad = self.assetIDs
            .subtracting(Set(inProgressTasks.keys))
            .subtracting(Set(loadedAssets.keys))
        
        for assetID in assetIDsToLoad {
            let task = Task.detached(priority: .high) {
                try await self.loadAsset(assetID: assetID)
            }
            inProgressTasks[assetID] = task
        }
        
        if inProgressTasks.isEmpty {
            delegate?.onUpdate(self)
        }
    }
    
    private func storeLoadedAsset(
        assetID: String,
        loadedAsset: LoadedAsset
    ) {
        inProgressTasks[assetID] = nil
        
        guard assetIDs.contains(assetID) else { return }
        
        loadedAssets[assetID] = loadedAsset
        delegate?.onUpdate(self)
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
            
            let textureLoader = MTKTextureLoader(
                device: MetalInterface.shared.device)
            
            let texture = try await textureLoader.newTexture(
                data: assetData,
                options: [
                    .textureUsage: MTLTextureUsage.shaderRead.rawValue,
//                    .SRGB: false,
                ])
            
            try Task.checkCancellation()
            
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
