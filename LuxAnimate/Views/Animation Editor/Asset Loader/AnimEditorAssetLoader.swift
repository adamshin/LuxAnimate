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
    
    private var loadStartTime: TimeInterval = 0
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Interface
    
    func update(assetIDs: Set<String>) {
        Task {
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
            
            // My suspicion is that this is the problem.
            
            // While we're suspended here waiting for tasks
            // to finish, another update call comes along.
            // It sees no in progress tasks - since we
            // removed them - and proceeds with starting a
            // new set of loading tasks. So we have too
            // many tasks in memory, and memory use spikes.
            
            // I can test this by seeing if a "Starting
            // load" message appears in between these two
            // messages with emojis.
            
            // If so, I need to protect this whole method
            // from re-entrancy. I should use my semaphore
            // or concurrency limiter.
            
            print("🔴 Awaiting cancellation of \(cancelledTasks.count) tasks...")
            for task in cancelledTasks {
                _ = await task.result
            }
            print("🟢 Cancelled \(cancelledTasks.count) tasks.")
            
            let assetIDsToLoad = self.assetIDs
                .subtracting(Set(inProgressTasks.keys))
                .subtracting(Set(loadedAssets.keys))
            
            loadStartTime = ProcessInfo.processInfo.systemUptime
            print("""
                Starting load. \
                New: \(assetIDsToLoad.count), \
                Reused: \(self.loadedAssets.count)
                """)
            
            for assetID in assetIDsToLoad {
                let task = Task.detached(priority: .high) {
//                    try await self.concurrencyLimiter.run {
                        try await self.loadAsset(assetID: assetID)
//                    }
                }
                inProgressTasks[assetID] = task
            }
            
            if inProgressTasks.isEmpty {
                print("Finished load - no tasks")
                delegate?.onUpdate(self)
            }
        }
    }
    
    // MARK: - Internal Methods
    
    private func storeLoadedAsset(
        assetID: String,
        loadedAsset: LoadedAsset
    ) {
        inProgressTasks[assetID] = nil
        
        guard assetIDs.contains(assetID)
        else {
//            print("Cancelled loading asset (final check)")
            return
        }
        
        loadedAssets[assetID] = loadedAsset
        
        delegate?.onUpdate(self)
        
//        print("Loaded asset")
        
        if inProgressTasks.isEmpty {
            let loadEndTime = ProcessInfo.processInfo.systemUptime
            let loadTime = loadEndTime - loadStartTime
            let loadTimeMs = Int(loadTime * 1000)
            
            print("""
                Finished load. \
                Time: \(loadTimeMs) ms
                """)
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
//            print("Cancelled loading asset")
            
        } catch {
//            print("Error loading asset")
            
            await storeLoadedAsset(
                assetID: assetID,
                loadedAsset: .error)
        }
    }
    
}
