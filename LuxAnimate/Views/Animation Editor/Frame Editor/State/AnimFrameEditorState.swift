//
//  AnimFrameEditorState.swift
//

import Metal

@MainActor
protocol AnimFrameEditorStateDelegate: AnyObject {
    
    func changeState(
        _ s: AnimFrameEditorState,
        newState: AnimFrameEditorState)
    
    func setAssetLoaderAssetIDs(
        _ s: AnimFrameEditorState,
        assetIDs: Set<String>)
    
    func assetLoaderHasLoadedAssets(
        _ s: AnimFrameEditorState,
        assetIDs: Set<String>
    ) -> Bool
    
    func assetLoaderAsset(
        _ s: AnimFrameEditorState,
        assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset?
    
    func workspaceViewSize(
        _ s: AnimFrameEditorState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditorState
    ) -> EditorWorkspaceTransform
    
    func setEditInteractionEnabled(
        _ s: AnimFrameEditorState,
        enabled: Bool)
    
    func onEdit(
        _ s: AnimFrameEditorState,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet)
    
}

@MainActor
protocol AnimFrameEditorState: AnyObject {
    
    var delegate: AnimFrameEditorStateDelegate? { get set }
    
    func beginState()
    
    func onAssetLoaderUpdate()
    
    func onFrame() -> EditorWorkspaceSceneGraph?
    
}
