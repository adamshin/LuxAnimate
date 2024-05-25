//
//  DrawingEditorToolVC.swift
//

import UIKit
import Metal

protocol DrawingEditorToolVCDelegate: AnyObject {
    
    func onUpdateActiveDrawingTexture(
        _ vc: DrawingEditorToolVC)
    
    func onEditDrawing(
        _ vc: DrawingEditorToolVC,
        drawingTexture: MTLTexture)
    
}


protocol DrawingEditorToolVC: UIViewController {
    
    var delegate: DrawingEditorToolVCDelegate? { get set }
    
    func clearDrawingTexture()
    func setDrawingTexture(_ texture: MTLTexture)
    func onFrame()
    
    func setEditingEnabled(_ enabled: Bool)
    func endActiveEdit()
    
    var activeDrawingTexture: MTLTexture? { get }
    
    func setBrushScale(_ brushScale: Double)
    func setBrushSmoothing(_ brushSmoothing: Double)
    
}
