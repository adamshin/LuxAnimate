//
//  AnimEditorAssetLoader.swift
//

import Metal

protocol AnimEditorAssetLoaderDelegate: AnyObject {
    
    func onLoadAsset(_ l: AnimEditorAssetLoader)
    func onFinishLoadingAssets(_ l: AnimEditorAssetLoader)
    
    func onError(_ l: AnimEditorAssetLoader)
    
}

class AnimEditorAssetLoader {
    
    private enum LoadedAsset {
        case loaded(MTLTexture)
        case error
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
    
    func assetTexture(assetID: String) -> MTLTexture? {
        guard let loadedAsset = loadedAssets[assetID]
        else { return nil }
        
        return switch loadedAsset {
        case .loaded(let texture): texture
        case .error: nil
        }
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
            delegate?.onFinishLoadingAssets(self)
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
                self.delegate?.onLoadAsset(self)
                
            } catch {
                if !(error is CancelLoadError) {
                    self.loadedAssets[assetID] = .error
                    self.delegate?.onError(self)
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
        
        let assetURL = FileHelper.shared.projectAssetURL(
            projectID: self.projectID,
            assetID: assetID)
        
        let encodedData = try Data(contentsOf: assetURL)
        
        guard shouldContinue() 
        else { throw CancelLoadError() }
        
        do {
            let output = try JXLDecoder.decode(
                data: encodedData,
                progress: {
                    self.assetIDs.contains(assetID)
                })
            
            let texture = try TextureCreator.createTexture(
                imageData: output.data,
                size: PixelSize(
                    width: output.width,
                    height: output.height),
                mipMapped: false,
                usage: .shaderRead)
            
            guard self.assetIDs.contains(assetID)
            else { throw CancelLoadError() }
            
            return texture
            
        } catch JXLDecoder.DecodingError.cancelled {
            throw CancelLoadError()
            
        } catch {
            throw error
        }
    }
    
}
