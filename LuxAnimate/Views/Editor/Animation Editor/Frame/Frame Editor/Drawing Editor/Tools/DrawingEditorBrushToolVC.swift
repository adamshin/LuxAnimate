//
//  DrawingEditorBrushToolVC.swift
//

import UIKit
import Metal

private let defaultBrushScale: Double = 0.2
private let defaultBrushSmoothing: Double = 0

private let brushColor: Color = .brushBlack

private var lastPaintBrushScale: Double?
private var lastPaintBrushSmoothing: Double?
private var lastEraseBrushScale: Double?
private var lastEraseBrushSmoothing: Double?

class DrawingEditorBrushToolVC:
    UIViewController, DrawingEditorToolVC
{
    weak var delegate: DrawingEditorToolVCDelegate?
    
    private let brushMode: BrushEngine.BrushMode
    
    private let brushEngine: BrushEngine
    private let brush: Brush
    
    private let brushGesture = BrushGestureRecognizer()
    
    var brushScale: Double = 0 {
        didSet {
            switch brushMode {
            case .paint:
                lastPaintBrushScale = brushScale
            case .erase:
                lastEraseBrushScale = brushScale
            }
        }
    }
    var brushSmoothing: Double = 0 {
        didSet {
            switch brushMode {
            case .paint:
                lastPaintBrushSmoothing = brushSmoothing
            case .erase:
                lastEraseBrushSmoothing = brushSmoothing
            }
        }
    }
    
    private var isDrawingSet = false
    private var isEditingEnabled = true
    
    // MARK: - Init
    
    init(
        brushConfig: Brush.Configuration,
        brushMode: BrushEngine.BrushMode,
        drawingSize: PixelSize,
        canvasContentView: UIView
    ) {
        self.brushMode = brushMode
        
        brushEngine = BrushEngine(
            canvasSize: drawingSize,
            brushMode: brushMode)
        
        brush = try! Brush(configuration: brushConfig)
        
        super.init(nibName: nil, bundle: nil)
        brushEngine.delegate = self
        
        canvasContentView.addGestureRecognizer(brushGesture)
        brushGesture.gestureDelegate = self
        
        switch brushMode {
        case .paint:
            brushScale = lastPaintBrushScale ?? defaultBrushScale
            brushSmoothing = lastPaintBrushSmoothing ?? defaultBrushSmoothing
        case .erase:
            brushScale = lastEraseBrushScale ?? defaultBrushScale
            brushSmoothing = lastEraseBrushSmoothing ?? defaultBrushSmoothing
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        brushGesture.view?.removeGestureRecognizer(brushGesture)
    }
    
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
        
        brushEngine.setCanvasTexture(texture)
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    func endActiveEdit() {
        brushGesture.reset()
        brushEngine.endStroke()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        if !enabled {
            endActiveEdit()
        }
        
        isEditingEnabled = enabled
        brushGesture.isEnabled = enabled
    }
    
    var activeDrawingTexture: MTLTexture? {
        isDrawingSet ? 
            brushEngine.activeCanvasTexture :
            nil
    }
    
}

// MARK: - Delegates

extension DrawingEditorBrushToolVC: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        guard isDrawingSet, isEditingEnabled
        else { return }
        
        brushEngine.beginStroke(
            brush: brush,
            color: brushColor,
            scale: brushScale,
            smoothing: brushSmoothing,
            quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke() {
        brushEngine.cancelStroke()
    }
    
}

extension DrawingEditorBrushToolVC: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) {
        delegate?.onUpdateActiveDrawingTexture(self)
    }
    
    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) {
        delegate?.onEditDrawing(self,
            drawingTexture: canvasTexture)
    }
    
}
