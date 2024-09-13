//
//  SafeAssetLoader.swift
//

import Metal

extension SafeAssetLoader {
    
    protocol Delegate: AnyObject {
        
        func pendingAssetData(
            _ l: SafeAssetLoader,
            assetID: String
        ) async -> Data?
        
        func onUpdate(_ l: SafeAssetLoader)
        func onFinish(_ l: SafeAssetLoader)
        
    }
    
    enum LoadedAsset {
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

actor SafeAssetLoader {
    
    private let projectID: String
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        delegate: Delegate?
    ) {
        self.projectID = projectID
        self.delegate = delegate
    }
    
    // MARK: - Interface
    
    func update(assetIDs: Set<String>) {
        
    }
    
    func loadedAsset(assetID: String) -> LoadedAsset? {
        nil
    }
    
    // MARK: - Internal Methods
    
    
    
}

// Limiter

actor LimitedConcurrencyQueue {
    private var queue: [CheckedContinuation<Void, Error>] = []
    private var runningCount = 0
    private let maxConcurrent: Int

    init(maxConcurrent: Int) {
        self.maxConcurrent = maxConcurrent
    }

    func enqueue<T: Sendable>(_ work: @escaping () async throws -> T) async throws -> T {
        if runningCount >= maxConcurrent {
            try await withCheckedThrowingContinuation { continuation in
                queue.append(continuation)
            }
        }
        
        runningCount += 1
        defer {
            runningCount -= 1
            if let next = queue.first {
                queue.removeFirst()
                next.resume()
            }
        }
        
        return try await work()
    }
}
