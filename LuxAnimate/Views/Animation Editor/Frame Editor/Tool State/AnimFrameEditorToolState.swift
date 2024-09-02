//
//  AnimFrameEditorToolState.swift
//

import Metal

protocol AnimFrameEditorToolState: AnyObject {
    
    func onFrame()
    func drawingCanvasTexture() -> MTLTexture
    
}
