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
        imageData: Data,
        imageSize: PixelSize)
    
}

class EditorFrameDrawingEditorVC: UIViewController {
    
    weak var delegate: EditorFrameDrawingEditorVCDelegate?
    
    private let brushGesture = BrushGestureRecognizer()
    
    private let brushEngine: BrushEngine
    private var brushMode: BrushEngine.BrushMode = .brush
    private let brush = try! Brush(configuration: brushConfig)
    
    private(set) var isDrawingSet = false
    private var isEditingEnabled = true
    
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
    
    func setDrawingTexture(_ texture: MTLTexture) {
        isDrawingSet = true
        brushEngine.endStroke()
        brushEngine.setCanvasContents(texture)
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    func endEditing() {
        brushEngine.endStroke()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        isEditingEnabled = enabled
        brushGesture.isEnabled = enabled
    }
    
    var drawingTexture: MTLTexture {
        brushEngine.canvasTexture
    }
    
}

// MARK: - Delegates

extension EditorFrameDrawingEditorVC: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        guard isEditingEnabled, isDrawingSet
        else { return }
        
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
    }
    
    func onCancelBrushStroke() {
        guard isEditingEnabled, isDrawingSet
        else { return }
        
        brushEngine.cancelStroke()
    }
    
}

extension EditorFrameDrawingEditorVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        delegate?.onUpdateCanvas(self)
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        do {
            let imageData = try TextureDataReader
                .read(brushEngine.canvasTexture)
            
            let imageSize = brushEngine.canvasSize
            
            delegate?.onEditDrawing(self,
                imageData: imageData,
                imageSize: imageSize)
            
        } catch { }
    }
    
}
