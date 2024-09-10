//
//  AnimEditorAssetLoader.swift
//

import Metal

// TODO: Make this thread safe

protocol AnimEditorAssetLoaderDelegate: AnyObject {
    
    func pendingAssetData(
        _ l: AnimEditorAssetLoader,
        assetID: String
    ) -> Data?
    
    func onUpdate(_ l: AnimEditorAssetLoader)
    func onFinish(_ l: AnimEditorAssetLoader)
    
}

class AnimEditorAssetLoader {
    
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
    
    private struct CancelLoadError: Error { }
    
    weak var delegate: AnimEditorAssetLoaderDelegate?
    
    private let projectID: String
    
    private let loadQueue = DispatchQueue(
        label: "AnimEditorAssetLoader.loadQueue",
        qos: .background)
    
    private var assetIDs: Set<String> = []
    private var loadedAssets: [String: LoadedAsset] = [:]
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Interface
    
    func update(assetIDs: Set<String>) {
        self.assetIDs = assetIDs
        
        loadedAssets = loadedAssets.filter { assetID, _ in
            assetIDs.contains(assetID)
        }
        
        loadNextAsset()
    }
    
    func loadedAsset(assetID: String) -> LoadedAsset? {
        loadedAssets[assetID]
    }
    
    func storeAssetTexture(
        assetID: String,
        texture: MTLTexture
    ) {
        assetIDs.insert(assetID)
        loadedAssets[assetID] = .loaded(texture)
    }
    
    // MARK: - Loading
    
    private func loadNextAsset() {
        let assetID = assetIDs.first {
            !loadedAssets.keys.contains($0)
        }
        guard let assetID else {
            DispatchQueue.main.async {
                self.delegate?.onUpdate(self)
                self.delegate?.onFinish(self)
            }
            return
        }
        
        loadQueue.async {
            do {
                let texture = try self.loadAsset(
                    assetID: assetID,
                    shouldContinue: {
                        self.assetIDs.contains(assetID)
                    })
                
                self.loadedAssets[assetID] = .loaded(texture)
                
                DispatchQueue.main.async {
                    self.delegate?.onUpdate(self)
                }
                
            } catch {
                if !(error is CancelLoadError) {
                    self.loadedAssets[assetID] = .error
                    
                    DispatchQueue.main.async {
                        self.delegate?.onUpdate(self)
                    }
                }
            }
            
            self.loadNextAsset()
        }
    }
    
    private func loadAsset(
        assetID: String,
        shouldContinue: () -> Bool
    ) throws -> MTLTexture {
        
        guard shouldContinue() 
        else { throw CancelLoadError() }
        
        if let assetData = delegate?
            .pendingAssetData(self, assetID: assetID)
        {
            return try loadAsset(
                assetID: assetID,
                assetData: assetData,
                shouldContinue: shouldContinue)
            
        } else {
            let assetURL = FileHelper.shared.projectAssetURL(
                projectID: self.projectID,
                assetID: assetID)
            
            let assetData = try Data(contentsOf: assetURL)
            
            return try loadAsset(
                assetID: assetID,
                assetData: assetData,
                shouldContinue: shouldContinue)
        }
    }
    
    private func loadAsset(
        assetID: String,
        assetData: Data,
        shouldContinue: () -> Bool
    ) throws -> MTLTexture {
        
        guard shouldContinue()
        else { throw CancelLoadError() }
        
        do {
            let output = try JXLDecoder.decode(
                data: assetData,
                progress: {
                    true//shouldContinue()
                })
            
            let texture = try TextureCreator.createTexture(
                imageData: output.data,
                size: PixelSize(
                    width: output.width,
                    height: output.height),
                mipMapped: false,
                usage: .shaderRead)
            
            guard shouldContinue()
            else { throw CancelLoadError() }
            
            return texture
            
        } catch JXLDecoder.DecodingError.cancelled {
            throw CancelLoadError()
            
        } catch {
            throw error
        }
    }
    
}
