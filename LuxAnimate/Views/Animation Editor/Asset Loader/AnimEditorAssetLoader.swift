//
//  AnimEditorAssetLoader.swift
//

import Metal

protocol AnimEditorAssetLoaderDelegate: AnyObject {
    
    func onLoadAsset(_ loader: AnimEditorAssetLoader)
    func onError(_ loader: AnimEditorAssetLoader)
    
}

class AnimEditorAssetLoader {
    
    private struct CancelLoadError: Error { }
    
    weak var delegate: AnimEditorAssetLoaderDelegate?
    
    private let projectID: String
    
    private let loadQueue = DispatchQueue(
        label: "AnimEditorAssetLoader.loadQueue",
        qos: .background)
    
    private var assetIDsToLoad: Set<String> = []
    private var loadedAssets: [String: MTLTexture] = [:]
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
    }
    
    // MARK: - Interface
    
    func update(assetIDsToLoad: Set<String>) {
        self.assetIDsToLoad = assetIDsToLoad
        
        loadedAssets = loadedAssets.filter { assetID, _ in
            assetIDsToLoad.contains(assetID)
        }
        
        loadNextAsset()
    }
    
    func assetTexture(id: String) -> MTLTexture? {
        loadedAssets[id]
    }
    
    // MARK: - Loading
    
    private func loadNextAsset() {
        let assetID = assetIDsToLoad.first {
            !loadedAssets.keys.contains($0)
        }
        guard let assetID else { return }
        
        loadQueue.async {
            do {
                let texture = try self.loadAsset(
                    assetID: assetID,
                    shouldContinue: {
                        self.assetIDsToLoad.contains(assetID)
                    })
                
                self.loadedAssets[assetID] = texture
                self.delegate?.onLoadAsset(self)
                
                self.loadNextAsset()
                
            } catch is CancelLoadError {
                self.loadNextAsset()
                
            } catch {
                self.delegate?.onError(self)
                self.loadNextAsset()
            }
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
                    self.assetIDsToLoad.contains(assetID)
                })
            
            let texture = try TextureCreator.createTexture(
                imageData: output.data,
                size: PixelSize(
                    width: output.width,
                    height: output.height),
                mipMapped: false,
                usage: .shaderRead)
            
            guard self.assetIDsToLoad.contains(assetID)
            else { throw CancelLoadError() }
            
            return texture
            
        } catch JXLDecoder.DecodingError.cancelled {
            throw CancelLoadError()
            
        } catch {
            throw error
        }
    }
    
}
