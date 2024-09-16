//
//  AnimFrameEditor.swift
//

import Metal

extension AnimFrameEditor {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func workspaceViewSize(
            _ e: AnimFrameEditor
        ) -> Size
        
        func workspaceTransform(
            _ e: AnimFrameEditor
        ) -> EditorWorkspaceTransform
        
        func setAssetLoaderAssetIDs(
            _ e: AnimFrameEditor,
            assetIDs: Set<String>)
        
        func assetLoaderAssetTexture(
            _ e: AnimFrameEditor,
            assetID: String
        ) -> MTLTexture?
        
        func setEditInteractionEnabled(
            _ e: AnimFrameEditor,
            enabled: Bool)
        
        func onEdit(
            _ e: AnimFrameEditor,
            drawingID: String,
            drawingTexture: MTLTexture?)
        
    }
    
}

@MainActor
class AnimFrameEditor {
    
    private var state: AnimFrameEditorState?
    
    weak var delegate: Delegate?
    
    // MARK: - State
    
    private func enterState(_ newState: AnimFrameEditorState) {
        state = newState
        newState.delegate = self
        newState.beginState()
    }
    
    // MARK: - Interface
    
    func begin(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        editorToolState: AnimEditorToolState
    ) {
        let state = AnimFrameEditorLoadingState(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig,
            editorToolState: editorToolState)
        
        enterState(state)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        state?.onFrame()
    }
    
    func onAssetLoaderUpdate() {
        state?.onAssetLoaderUpdate()
    }
    
    func onAssetLoaderFinish() {
        state?.onAssetLoaderFinish()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditor: AnimFrameEditorStateDelegate {
    
    func changeState(
        _ s: AnimFrameEditorState,
        newState: AnimFrameEditorState
    ) {
        enterState(newState)
    }
    
    func setAssetLoaderAssetIDs(
        _ s: AnimFrameEditorState,
        assetIDs: Set<String>
    ) {
        delegate?.setAssetLoaderAssetIDs(
            self, 
            assetIDs: assetIDs)
    }
    
    func assetLoaderAssetTexture(
        _ s: AnimFrameEditorState,
        assetID: String
    ) -> MTLTexture? {
        delegate?.assetLoaderAssetTexture(
            self,
            assetID: assetID)
    }
    
    func workspaceViewSize(
        _ s: AnimFrameEditorState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func setEditInteractionEnabled(
        _ s: any AnimFrameEditorState,
        enabled: Bool
    ) {
        delegate?.setEditInteractionEnabled(
            self, enabled: enabled)
    }
    
    func onEdit(
        _ s: AnimFrameEditorState,
        drawingID: String,
        drawingTexture: MTLTexture?
    ) {
        delegate?.onEdit(self,
            drawingID: drawingID,
            drawingTexture: drawingTexture)
    }
    
}
