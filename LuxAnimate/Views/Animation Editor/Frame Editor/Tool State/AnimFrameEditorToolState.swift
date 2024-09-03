//
//  AnimFrameEditorToolState.swift
//

import Metal

protocol AnimFrameEditorToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditorToolState
    ) -> EditorWorkspaceTransform
    
    func layerContentSize(
        _ s: AnimFrameEditorToolState
    ) -> Size
    
    func layerTransform(
        _ s: AnimFrameEditorToolState
    ) -> Matrix3
    
    // TODO: Methods for reporting edits
    
}

protocol AnimFrameEditorToolState: AnyObject {
    
    var delegate: AnimFrameEditorToolStateDelegate? { get set }
    
    func onFrame()
    
}
