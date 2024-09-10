//
//  AnimEditManager.swift
//

import Metal

protocol AnimEditManagerDelegate: AnyObject {
    
    func onRequestSceneEdit(
        _ m: AnimEditManager,
        sceneEdit: ProjectEditHelper.SceneEdit)
    
}

class AnimEditManager {
    
    private var sceneManifest: Scene.Manifest
    
    private let drawingAssetProcessor = DrawingAssetProcessor()
    
    weak var delegate: AnimEditManagerDelegate?
    
    // MARK: - Init
    
    init(
        sceneManifest: Scene.Manifest
    ) {
        self.sceneManifest = sceneManifest
    }
    
    // MARK: - Interface
    
    func update(
        sceneManifest: Scene.Manifest
    ) {
        self.sceneManifest = sceneManifest
    }
    
    func applyEdit(
        drawingID: String,
        drawingTexture: MTLTexture?
    ) {
        // TODO: Schedule this work on a background queue
        guard let drawingTexture else { return }
        
        do {
            let texture = try TextureCopier
                .copy(drawingTexture)
            
            let imageSet = try drawingAssetProcessor
                .generate(sourceTexture: texture)
            
            let sceneEdit = try SceneEditHelper.editDrawing(
                sceneManifest: sceneManifest,
                drawingID: drawingID,
                imageSet: imageSet)
            
            delegate?.onRequestSceneEdit(
                self, sceneEdit: sceneEdit)
            
        } catch { }
    }
    
    func afterAllEditsFinish(_ block: @escaping () -> Void) {
        // TODO: Actually wait for pending tasks
        DispatchQueue.main.async {
            block()
        }
    }
    
}
