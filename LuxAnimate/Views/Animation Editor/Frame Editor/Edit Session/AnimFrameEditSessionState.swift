//
//  AnimFrameEditSessionState.swift
//

import Foundation
import Geometry

@MainActor
protocol AnimFrameEditSessionStateDelegate: AnyObject {
    
    func changeState(
        _ s: AnimFrameEditSessionState,
        newState: AnimFrameEditSessionState)
    
    func workspaceViewSize(_ s: AnimFrameEditSessionState)
    -> Size
    
    func workspaceTransform(_ s: AnimFrameEditSessionState)
    -> EditorWorkspaceTransform
    
    func onRequestLoadAssets(
        _ s: AnimFrameEditSessionState,
        assetIDs: Set<String>)
    
    func hasLoadedAssets(
        _ s: AnimFrameEditSessionState,
        assetIDs: Set<String>
    ) -> Bool
    
    func asset(
        _ s: AnimFrameEditSessionState,
        assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset?
    
    func onRequestEdit(
        _ s: AnimFrameEditSessionState,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet)
    
}

@MainActor
protocol AnimFrameEditSessionState: AnyObject {
    
    var delegate: AnimFrameEditSessionStateDelegate? { get set }
    
    func begin()
    
    func onFrame() -> EditorWorkspaceSceneGraph?
    func onAssetLoaderUpdate()
    
}
