//
//  DrawingEditorBrushToolVC.swift
//

import UIKit
import Metal

private let brushColor: Color = .brushBlack

class DrawingEditorBrushToolVC:
    UIViewController, DrawingEditorToolVC
{
    weak var delegate: DrawingEditorToolVCDelegate?
    
    private let brushMode: BrushEngine.BrushMode
    
    private let brushEngine: BrushEngine
    
    private var scale: Double = 0
    private var smoothing: Double = 0
    
    private let brush = try! Brush(
        configuration: AppConfig.brushConfig)
    
    private let brushGesture = BrushGestureRecognizer()
    
    private var isDrawingSet = false
    private var isEditingEnabled = true
    
    // MARK: - Init
    
    init(
        brushMode: BrushEngine.BrushMode,
        drawingSize: PixelSize,
        canvasContentView: UIView
    ) {
        self.brushMode = brushMode
        
        brushEngine = BrushEngine(canvasSize: drawingSize)
        
        super.init(nibName: nil, bundle: nil)
        brushEngine.delegate = self
        
        canvasContentView.addGestureRecognizer(brushGesture)
        brushGesture.gestureDelegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    // MARK: - Interface
    
    func clearDrawingTexture() {
        isDrawingSet = false
    }
    
    func setDrawingTexture(_ texture: MTLTexture) {
        guard !isDrawingSet else { return }
        
        isDrawingSet = true
        brushEngine.endStroke()
        brushEngine.setCanvasContents(texture)
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    func endActiveEdit() {
        brushGesture.reset()
        brushEngine.endStroke()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        isEditingEnabled = enabled
        brushGesture.isEnabled = enabled
    }
    
    var activeDrawingTexture: MTLTexture? {
        isDrawingSet ? brushEngine.canvasTexture : nil
    }
    
    func setBrushScale(_ brushScale: Double) {
        self.scale = brushScale
    }
    
    func setBrushSmoothing(_ brushSmoothing: Double) {
        self.smoothing = brushSmoothing
    }
    
}

// MARK: - Delegates

extension DrawingEditorBrushToolVC: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        guard isDrawingSet, isEditingEnabled
        else { return }
        
        brushEngine.beginStroke(
            brush: brush,
            brushMode: brushMode,
            color: brushColor,
            scale: scale,
            quickTap: quickTap,
            smoothing: smoothing)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        guard isDrawingSet, isEditingEnabled
        else { return }
        
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        guard isDrawingSet, isEditingEnabled
        else { return }
        
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke() {
        guard isDrawingSet, isEditingEnabled
        else { return }
        
        brushEngine.cancelStroke()
    }
    
}

extension DrawingEditorBrushToolVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        delegate?.onUpdateActiveDrawingTexture(self)
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        delegate?.onEditDrawing(self,
            drawingTexture: brushEngine.canvasTexture)
    }
    
}
