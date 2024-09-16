//
//  AnimFrameEditProcessor.swift
//

// TODO: This object should keep a queue of frame edits.
// A frame edit is just an updated drawing texture for now.
// In the future, we may also include updates to the
// selection mask or active transform.

// The idea here is to perform heavy work (encoding and
// resizing images) in the background, without blocking
// the main thread. The user may input multiple fast edits
// when drawing quick brush strokes. We need to stay
// responsive while also saving their changes.

// The queue should have a limit so we don't use too much
// memory. I think 3 would be plenty. If we're at the limit
// and the user inputs another edit, we should probably
// drop one of the edits in the queue to make room. The
// downside of this is we'd lose an undo/redo step. This
// should be rare in practice, though.

import Metal

extension AnimFrameEditProcessor {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestSceneEdit(
            _ p: AnimFrameEditProcessor,
            sceneEdit: ProjectEditHelper.SceneEdit)
        
    }
    
}

@MainActor
class AnimFrameEditProcessor {
    
    private let layerID: String
    
    private let drawingAssetProcessor = DrawingAssetProcessor()
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(
        layerID: String
    ) {
        self.layerID = layerID
    }
    
    // MARK: - Interface
    
    func applyEdit(
        sceneManifest: Scene.Manifest,
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
                layerID: layerID,
                drawingID: drawingID,
                imageSet: imageSet)
            
            delegate?.onRequestSceneEdit(
                self, sceneEdit: sceneEdit)
            
        } catch { }
    }
    
}
