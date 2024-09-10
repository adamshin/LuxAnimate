//
//  AnimFrameEditor.swift
//

import Metal

protocol AnimFrameEditorDelegate: AnyObject {
    
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
        assetID: String) -> MTLTexture?
    
    func storeAssetLoaderTexture(
        _ e: AnimFrameEditor,
        assetID: String,
        texture: MTLTexture)
    
    func setEditInteractionEnabled(
        _ e: AnimFrameEditor,
        enabled: Bool)
    
    func onEdit(
        _ e: AnimFrameEditor,
        drawingID: String,
        drawingTexture: MTLTexture?)
    
}

class AnimFrameEditor {
    
    private var state: AnimFrameEditorState?
    
    weak var delegate: AnimFrameEditorDelegate?
    
    // MARK: - State
    
    private func enterState(_ newState: AnimFrameEditorState) {
        state = newState
        newState.delegate = self
        newState.beginState()
    }
    
    // MARK: - Interface
    
    func begin(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        editorToolState: AnimEditorToolState
    ) {
        do {
            let state = try AnimFrameEditorLoadingState(
                projectID: projectID,
                sceneID: sceneID,
                activeLayerID: activeLayerID,
                activeFrameIndex: activeFrameIndex,
                onionSkinConfig: onionSkinConfig,
                projectManifest: projectManifest,
                sceneManifest: sceneManifest,
                editorToolState: editorToolState)
            
            enterState(state)
            
        } catch { }
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
    
    func storeAssetLoaderTexture(
        _ s: AnimFrameEditorState,
        assetID: String,
        texture: MTLTexture
    ) {
        delegate?.storeAssetLoaderTexture(
            self, 
            assetID: assetID,
            texture: texture)
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
        // Do we report this up the chain?
        // Maybe it goes all the way to the AnimEditorVC.
        // In this scenario, the AnimEditorVC will maintain
        // a queue of tasks.
        
        // Maybe when switching tools, we should halt the
        // main thread until all pending tasks are complete.
        // Except that may not work... we wouldn't have
        // up-to-date data still at that point, because
        // edit updates would be dispatched to the main
        // queue and execute after.
        
        // Maybe we'd have to wait for all tasks to finish,
        // then dispatch the tool switching code to the
        // main queue after that.
    }
    
}
