//
//  AnimationFrameEditor.swift
//

import Foundation
import Metal

protocol AnimationFrameEditorDelegate: AnyObject {
    
    func onFinishLoadingAssets(
        _ editor: AnimationFrameEditor)
    
    func onUpdateViewportTexture(
        _ editor: AnimationFrameEditor,
        viewportTexture: MTLTexture)
    
    func onRequestApplyEdit(
        _ editor: AnimationFrameEditor,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class AnimationFrameEditor {
    
    weak var delegate: AnimationFrameEditorDelegate?
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    
    private var sceneManifest: Scene.Manifest
    
    private let frameScene: AnimationEditorScene
    private let assetLoader: AnimationFrameEditorAssetLoader
    
    private let renderer = AnimationEditorSceneRenderer()
    
    // Drawing edit session
    
    // Have a way of getting all currently loaded assets
    // so they can be reused if this edit session is
    // replaced.
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        delegate: AnimationFrameEditorDelegate
    ) {
        self.delegate = delegate
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        self.sceneManifest = sceneManifest
        
        frameScene = AnimationEditorScene.generate(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinPrevCount: onionSkinPrevCount,
            onionSkinNextCount: onionSkinNextCount)
        
        let allDrawings = frameScene.allDrawings()
        
        assetLoader = AnimationFrameEditorAssetLoader(
            projectID: projectID)
        
        assetLoader.delegate = self
        assetLoader.loadAssets(drawings: allDrawings)
        
        renderer.delegate = self
    }
    
    func drawViewport() -> MTLTexture {
        // TODO: Draw
    }
    
}

extension AnimationFrameEditor: AnimationFrameEditorAssetLoaderDelegate {
    
    func onFinishLoading(
        _ loader: AnimationFrameEditorAssetLoader
    ) {
        delegate?.onFinishLoadingAssets(self)
    }
    
}

extension AnimationFrameEditor: AnimationEditorSceneRendererDelegate {
    
    func textureForDrawing(
        _ r: AnimationEditorSceneRenderer,
        drawingID: String
    ) -> MTLTexture? {
        
        // TODO: If this is the active drawing, return the
        // active framebuffer from the drawing editor.
        
//        if drawingID == frameScene.activeDrawingID {
//            return nil
//        } else {
            let asset = assetLoader.asset(for: drawingID)
            return asset?.texture
//        }
    }
    
}
