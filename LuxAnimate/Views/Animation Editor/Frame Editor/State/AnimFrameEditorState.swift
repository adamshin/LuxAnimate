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
    
    func applyDrawingEdit(
        _ e: AnimFrameEditorState,
        drawingID: String,
        drawingTexture: MTLTexture)
    
}

protocol AnimFrameEditorState: AnyObject {
    
    var delegate: AnimFrameEditorStateDelegate? { get set }
    
    func beginState()
    
    func onLoadAsset()
    func onFinishLoadingAssets()
    
    func onFrame() -> EditorWorkspaceSceneGraph?
    
}
