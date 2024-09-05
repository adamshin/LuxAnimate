//
//  AnimFrameEditorState.swift
//

import Metal

protocol AnimFrameEditorStateDelegate: AnyObject {
    
    func changeState(
        _ e: AnimFrameEditorState,
        newState: AnimFrameEditorState)
    
    func setAssetLoaderAssetIDs(
        _ s: AnimFrameEditorState,
        assetIDs: Set<String>)
    
    func assetLoaderAssetTexture(
        _ e: AnimFrameEditorState,
        assetID: String) -> MTLTexture?
    
    func storeAssetLoaderTexture(
        _ e: AnimFrameEditorState,
        assetID: String,
        texture: MTLTexture)
    
    func workspaceViewSize(
        _ e: AnimFrameEditorState
    ) -> Size
    
    func workspaceTransform(
        _ e: AnimFrameEditorState
    ) -> EditorWorkspaceTransform
    
    func setEditInteractionEnabled(
        _ e: AnimFrameEditorState,
        enabled: Bool)
    
    // I'm passing the whole drawing here for testing.
    // In the future, we should just pass the ID.
    func applyDrawingEdit(
        _ e: AnimFrameEditorState,
        drawing: Scene.Drawing,
        drawingTexture: MTLTexture)
    
}

protocol AnimFrameEditorState: AnyObject {
    
    var delegate: AnimFrameEditorStateDelegate? { get set }
    
    func beginState()
    
    func onFrame() -> EditorWorkspaceSceneGraph?
    func onLoadAsset()
    
}
