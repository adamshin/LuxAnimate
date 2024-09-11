//
//  DrawingEditorToolVC.swift
//

import UIKit
import Metal

@MainActor
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
    
    var brushScale: Double { get set }
    var brushSmoothing: Double { get set }
    
}
