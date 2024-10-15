//
//  AnimFrameEditorToolState.swift
//

import Metal

@MainActor
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
    
    func onEdit(
        _ s: AnimFrameEditorToolState,
        imageSet: DrawingAssetProcessor.ImageSet)
    
}

@MainActor
protocol AnimFrameEditorToolState: AnyObject {
    
    var delegate: AnimFrameEditorToolStateDelegate? { get set }
    
    func onFrame()
    
    func drawingCanvasTexture() -> MTLTexture
    func setDrawingCanvasTextureContents(_ texture: MTLTexture)
    
}
