//
//  EditorFrameDrawingEditorVC.swift
//

import UIKit
import Metal

// For now, this is just the brush tool.
// We'll need to add other modes and overlays.

private let brushConfig = Brush.Configuration(
    stampTextureName: "brush1.png",
    stampSize: 50,
    stampSpacing: 0.0,
    stampAlpha: 1,
    pressureScaling: 0.5,
    taperLength: 0.05,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlack

protocol EditorFrameDrawingEditorVCDelegate: AnyObject {
    
    func brushScale(
        _ vc: EditorFrameDrawingEditorVC
    ) -> Double
    
    func brushSmoothing(
        _ vc: EditorFrameDrawingEditorVC
    ) -> Double
    
    func onUpdateCanvas(
        _ vc: EditorFrameDrawingEditorVC)
    
    func onEditDrawing(
        _ vc: EditorFrameDrawingEditorVC,
        texture: MTLTexture)
    
}

class EditorFrameDrawingEditorVC: UIViewController {
    
    weak var delegate: EditorFrameDrawingEditorVCDelegate?
    
    private let brushGesture = BrushGestureRecognizer()
    
    private let brushEngine: BrushEngine
    private let brush = try! Brush(configuration: brushConfig)
    
    private var isDrawingSet = false
    
    private var isEditingEnabled = true
    private var hasActiveBrushStroke = false
    private var brushMode: BrushEngine.BrushMode = .brush
    
    // MARK: - Init
    
    init(
        drawingSize: PixelSize,
        canvasContentView: UIView
    ) {
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
    
    func clearDrawing() {
        isDrawingSet = false
    }
    
    func setDrawingTextureIfNeeded(_ texture: MTLTexture) {
        guard !isDrawingSet else {
            print("Not setting drawing texture - already set")
            return
        }
        guard !hasActiveBrushStroke else {
            print("Not setting drawing texture - active brush stroke")
            return
        }
        
        print("Setting drawing!!!")
        isDrawingSet = true
        brushEngine.endStroke()
        brushEngine.setCanvasContents(texture)
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    func endActiveEdit() {
        brushEngine.endStroke()
        hasActiveBrushStroke = false
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        isEditingEnabled = enabled
        brushGesture.isEnabled = enabled
    }
    
    var hasActiveEdit: Bool {
        hasActiveBrushStroke
    }
    
    var drawingTexture: MTLTexture? {
        isDrawingSet ? brushEngine.canvasTexture : nil
    }
    
}

// MARK: - Delegates

extension EditorFrameDrawingEditorVC: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        guard isEditingEnabled, isDrawingSet
        else { return }
        
        hasActiveBrushStroke = true
        
        let scale = delegate?.brushScale(self) ?? 0
        let smoothing = delegate?.brushSmoothing(self) ?? 0
        
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
        guard isEditingEnabled, isDrawingSet
        else { return }
        
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        guard isEditingEnabled, isDrawingSet
        else { return }
        
        brushEngine.endStroke()
        hasActiveBrushStroke = false
    }
    
    func onCancelBrushStroke() {
        guard isEditingEnabled, isDrawingSet
        else { return }
        
        brushEngine.cancelStroke()
        hasActiveBrushStroke = false
    }
    
}

extension EditorFrameDrawingEditorVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        delegate?.onUpdateCanvas(self)
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        do {
            let texture = try TextureCopier
                .copy(brushEngine.canvasTexture)
            
            delegate?.onEditDrawing(self,
                texture: texture)
            
        } catch { }
    }
    
}
