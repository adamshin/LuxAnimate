//
//  AnimFrameEditSession.swift
//

import Foundation
import Geometry

extension AnimFrameEditSession {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func workspaceViewSize(_ s: AnimFrameEditSession)
        -> Size
        
        func workspaceTransform(_ s: AnimFrameEditSession)
        -> EditorWorkspaceTransform
        
        func loadAssets(
            _ s: AnimFrameEditSession,
            assetIDs: Set<String>)
        
        func hasLoadedAssets(
            _ s: AnimFrameEditSession,
            assetIDs: Set<String>
        ) -> Bool
        
        func asset(
            _ s: AnimFrameEditSession,
            assetID: String
        ) -> AnimEditorAssetLoader.LoadedAsset?
        
        func onRequestEdit(
            _ s: AnimFrameEditSession,
            drawingID: String,
            imageSet: DrawingAssetProcessor.ImageSet)
        
    }
    
}

@MainActor
class AnimFrameEditSession {
    
    private var state: AnimFrameEditSessionState?
    
    private weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?,
        editorToolState: AnimEditorToolState?,
        delegate: Delegate?
    ) {
        self.delegate = delegate

        let sceneGraph = AnimFrameEditorSceneGraph(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig)

        let loadingState = AnimFrameEditSessionLoadingState(
            sceneGraph: sceneGraph,
            editorToolState: editorToolState)

        beginState(loadingState)
    }
    
    // MARK: - State
    
    private func beginState(
        _ newState: AnimFrameEditSessionState
    ) {
        state = newState
        newState.delegate = self
        newState.begin()
    }
    
    // MARK: - Interface
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        state?.onFrame()
    }
    
    func onAssetLoaderUpdate() {
        state?.onAssetLoaderUpdate()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditSession:
    AnimFrameEditSessionStateDelegate {
    
    func changeState(
        _ s: AnimFrameEditSessionState,
        newState: AnimFrameEditSessionState
    ) {
        beginState(newState)
    }
    
    func workspaceViewSize(
        _ s: AnimFrameEditSessionState
    ) -> Geometry.Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditSessionState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func loadAssets(
        _ s: AnimFrameEditSessionState,
        assetIDs: Set<String>
    ) {
        delegate?.loadAssets(self, assetIDs: assetIDs)
    }
    
    func hasLoadedAssets(
        _ s: AnimFrameEditSessionState,
        assetIDs: Set<String>
    ) -> Bool {
        delegate?.hasLoadedAssets(
            self, assetIDs: assetIDs) ?? false
    }
    
    func asset(
        _ s: AnimFrameEditSessionState,
        assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset? {
        delegate?.asset(self, assetID: assetID)
    }
    
    func onRequestEdit(
        _ s: AnimFrameEditSessionState,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        delegate?.onRequestEdit(
            self,
            drawingID: drawingID,
            imageSet: imageSet)
    }
    
}
