//
//  AnimFrameEditorToolState.swift
//

import Metal

protocol AnimFrameEditorToolState: AnyObject {
    
    func onFrame()
    func clearCanvas()
    func drawingCanvasTexture() -> MTLTexture
    
}
