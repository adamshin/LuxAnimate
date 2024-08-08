//
//  AnimationFrameEditor.swift
//

import Foundation
import Metal

protocol AnimationFrameEditorDelegate: AnyObject {
    
    func onBegin(
        _ editor: AnimationFrameEditor,
        viewportSize: PixelSize)
    
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
    
    private let frameScene: AnimationEditorFrameScene
    private let assetLoader: AnimationFrameEditorAssetLoader
    private let renderer: AnimationFrameEditorRenderer
    
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
        
        frameScene = AnimationEditorFrameScene.generate(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinPrevCount: onionSkinPrevCount,
            onionSkinNextCount: onionSkinNextCount)
        
        let allDrawings = frameScene.allDrawings()
        
        assetLoader = AnimationFrameEditorAssetLoader(
            projectID: projectID)
        
        renderer = AnimationFrameEditorRenderer(
            viewportSize: frameScene.viewportSize)
        
        delegate.onBegin(self,
            viewportSize: frameScene.viewportSize)
        
        assetLoader.delegate = self
        assetLoader.loadAssets(drawings: allDrawings)
        
        renderer.delegate = self
    }
    
//    func drawViewport() -> MTLTexture {
//        
//    }
    
}

extension AnimationFrameEditor: AnimationFrameEditorAssetLoaderDelegate {
    
    func onFinishLoading(
        _ loader: AnimationFrameEditorAssetLoader
    ) {
        delegate?.onFinishLoadingAssets(self)
    }
    
}

extension AnimationFrameEditor: AnimationFrameEditorRendererDelegate {
    
    func textureForDrawing(
        _ r: AnimationFrameEditorRenderer,
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
