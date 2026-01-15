//
//  AnimFrameEditSessionToolState.swift
//

import Metal
import Geometry

@MainActor
protocol AnimFrameEditSessionToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: AnimFrameEditSessionToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditSessionToolState
    ) -> EditorWorkspaceTransform
    
    func layerContentSize(
        _ s: AnimFrameEditSessionToolState
    ) -> Size
    
    func layerTransform(
        _ s: AnimFrameEditSessionToolState
    ) -> Matrix3
    
    func onRequestEdit(
        _ s: AnimFrameEditSessionToolState,
        imageSet: DrawingAssetProcessor.ImageSet)
    
}

@MainActor
protocol AnimFrameEditSessionToolState: AnyObject {
    
    var delegate: AnimFrameEditSessionToolStateDelegate?
    { get set }
    
    func onFrame()
    
    func drawingCanvasTexture() -> MTLTexture
    func setDrawingCanvasTextureContents(_ texture: MTLTexture)
    
}

