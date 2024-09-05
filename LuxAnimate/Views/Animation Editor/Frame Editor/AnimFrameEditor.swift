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
    
    // TODO: Methods for reporting project edits
    
}

class AnimFrameEditor {
    
    private var state: AnimFrameEditorState?
    
    weak var delegate: AnimFrameEditorDelegate?
    
    // MARK: - Init
    
    init(
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
    
    // MARK: - State
    
    private func enterState(_ newState: AnimFrameEditorState) {
        state = newState
        newState.delegate = self
        newState.beginState()
    }
    
    // MARK: - Interface
    
    func onFrame() -> EditorWorkspaceSceneGraph? {
        state?.onFrame()
    }
    
    func onLoadAsset() {
        state?.onLoadAsset()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditor: AnimFrameEditorStateDelegate {
    
    func changeState(
        _ e: AnimFrameEditorState,
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
        _ e: AnimFrameEditorState,
        assetID: String
    ) -> MTLTexture? {
        delegate?.assetLoaderAssetTexture(
            self, 
            assetID: assetID)
    }
    
    func storeAssetLoaderTexture(
        _ e: AnimFrameEditorState,
        assetID: String,
        texture: MTLTexture
    ) {
        delegate?.storeAssetLoaderTexture(
            self, 
            assetID: assetID,
            texture: texture)
    }
    
    func workspaceViewSize(
        _ e: AnimFrameEditorState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ e: AnimFrameEditorState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func setEditInteractionEnabled(
        _ e: any AnimFrameEditorState,
        enabled: Bool
    ) {
        delegate?.setEditInteractionEnabled(
            self, enabled: enabled)
    }
    
    func applyDrawingEdit(
        _ e: AnimFrameEditorState,
        drawing: Scene.Drawing,
        drawingTexture: MTLTexture
    ) {
        // TODO: Save edit to disk.
        // For now, just save it in the asset loader.
        // This will be enough for testing.
        
        guard let assetID = drawing.assetIDs?.full,
            let texture = try? TextureCopier.copy(drawingTexture)
        else { return }
        
        delegate?.storeAssetLoaderTexture(
            self,
            assetID: assetID,
            texture: texture)
    }
    
}
