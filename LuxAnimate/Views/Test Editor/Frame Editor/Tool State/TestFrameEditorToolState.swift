//
//  TestFrameEditorToolState.swift
//

import Metal

protocol TestFrameEditorToolState: AnyObject {
    
    func onFrame()
    func clearCanvas()
    func drawingCanvasTexture() -> MTLTexture
    
}
