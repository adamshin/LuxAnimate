//
//  EditorFrameDrawingEditorVC.swift
//

import UIKit
import Metal

@MainActor
protocol EditorFrameDrawingEditorVCDelegate: AnyObject {
    
    func onSetBrushScale(
        _ vc: EditorFrameDrawingEditorVC,
        _ brushScale: Double)
    
    func onSetBrushSmoothing(
        _ vc: EditorFrameDrawingEditorVC,
        _ brushSmoothing: Double)
    
    func onUpdateActiveDrawingTexture(
        _ vc: EditorFrameDrawingEditorVC)
    
    func onEditDrawing(
        _ vc: EditorFrameDrawingEditorVC,
        drawingTexture: MTLTexture)
    
}

class EditorFrameDrawingEditorVC: UIViewController {
    
    weak var delegate: EditorFrameDrawingEditorVCDelegate?
    
    private let drawingSize: PixelSize
    private let canvasContentView: UIView
    
    private let drawingTexture: MTLTexture
    private var isDrawingTextureSet = false
    
    private let toolContainerVC = PassthroughContainerViewController()
    private var activeToolVC: DrawingEditorToolVC?
    
    // MARK: - Init
    
    init(
        drawingSize: PixelSize,
        canvasContentView: UIView
    ) throws {
        
        self.drawingSize = drawingSize
        self.canvasContentView = canvasContentView
        
        drawingTexture = try TextureCreator
            .createEmptyTexture(
                size: drawingSize,
                mipMapped: false)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(toolContainerVC, to: view)
    }
    
    // MARK: - Tools
    
    private func activateToolVC(_ vc: DrawingEditorToolVC) {
        vc.delegate = self
        toolContainerVC.show(vc)
        
        activeToolVC = vc
        
        if isDrawingTextureSet {
            vc.setDrawingTexture(drawingTexture)
        }
        
        // TODO: is this the right way of passing these values around?
        delegate?.onSetBrushScale(self, vc.brushScale)
        delegate?.onSetBrushSmoothing(self, vc.brushSmoothing)
    }
    
    // MARK: - Interface
    
    func clearDrawingTexture() {
        isDrawingTextureSet = false
        activeToolVC?.clearDrawingTexture()
    }
    
    func setDrawingTexture(_ drawingTexture: MTLTexture) {
        do {
            try TextureBlitter.blit(
                from: drawingTexture,
                to: self.drawingTexture)
            
            isDrawingTextureSet = true
            
            activeToolVC?.setDrawingTexture(drawingTexture)
            
        } catch { }
    }
    
    func onFrame() {
        activeToolVC?.onFrame()
    }
    
    func endActiveEdit() {
        activeToolVC?.endActiveEdit()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        activeToolVC?.setEditingEnabled(enabled)
    }
    
    var activeDrawingTexture: MTLTexture? {
        activeToolVC?.activeDrawingTexture
    }
    
    func selectBrushTool() {
        let vc = DrawingEditorBrushToolVC(
            brushConfig: AppConfig.paintBrushConfig,
            brushMode: .paint,
            drawingSize: drawingSize,
            canvasContentView: canvasContentView)
        
        activateToolVC(vc)
    }
    func selectEraseTool() {
        let vc = DrawingEditorBrushToolVC(
            brushConfig: AppConfig.eraseBrushConfig,
            brushMode: .erase,
            drawingSize: drawingSize,
            canvasContentView: canvasContentView)
        
        activateToolVC(vc)
    }
    
    func setBrushScale(_ brushScale: Double) {
        activeToolVC?.brushScale = brushScale
    }
    func setBrushSmoothing(_ brushSmoothing: Double) {
        activeToolVC?.brushSmoothing = brushSmoothing
    }
    
}

// MARK: - Delegates

extension EditorFrameDrawingEditorVC: DrawingEditorToolVCDelegate {
    
    func onUpdateActiveDrawingTexture(
        _ vc: any DrawingEditorToolVC
    ) {
        delegate?.onUpdateActiveDrawingTexture(self)
    }
    
    func onEditDrawing(
        _ vc: any DrawingEditorToolVC,
        drawingTexture: MTLTexture
    ) {
        do {
            try TextureBlitter.blit(
                from: drawingTexture,
                to: self.drawingTexture)
        } catch { }
        
        delegate?.onEditDrawing(self,
            drawingTexture: drawingTexture)
    }
    
}

// MARK: - Passthrough Container

private class PassthroughContainerViewController: ContainerViewController {
    
    override func loadView() {
        view = PassthroughView()
    }
    
}
