//
//  DrawingEditorBrushToolVC.swift
//

import UIKit
import Metal

// TODO: Load and save values
private let defaultBrushScale: Double = 0.2
private let defaultBrushSmoothing: Double = 0

private let brushColor: Color = .brushBlack

class DrawingEditorBrushToolVC:
    UIViewController, DrawingEditorToolVC
{
    weak var delegate: DrawingEditorToolVCDelegate?
    
    private let brushMode: BrushEngine.BrushMode
    
    private let brushEngine: BrushEngine
    
    var brushScale: Double = defaultBrushScale
    var brushSmoothing: Double = defaultBrushSmoothing
    
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
        
        brushEngine = BrushEngine(
            canvasSize: drawingSize,
            brushMode: .paint)
        
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
            quickTap: quickTap,
            smoothing: brushSmoothing)
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
