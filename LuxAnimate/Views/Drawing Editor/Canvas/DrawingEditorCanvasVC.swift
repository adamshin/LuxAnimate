//
//  DrawingEditorCanvasVC.swift
//

import UIKit
import Metal

private let minScaleLevel: Scalar = 0.1
private let maxScaleLevel: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

protocol DrawingEditorCanvasVCDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ vc: DrawingEditorCanvasVC)
    
    func onUpdateBrushStroke(
        _ vc: DrawingEditorCanvasVC,
        _ stroke: BrushStrokeGestureRecognizer.Stroke)
    
    func onEndBrushStroke(
        _ vc: DrawingEditorCanvasVC)
    
    func needsDrawLayer(
        _ vc: DrawingEditorCanvasVC)
    
}

class DrawingEditorCanvasVC: UIViewController {
    
    weak var delegate: DrawingEditorCanvasVCDelegate?
        
    private let metalView = MetalView()
    private let canvasView = MovableCanvasView()
    
    private let layerRenderer = MetalLayerTextureRenderer()
    
    private let canvasViewSize: Size
    
    // MARK: - Init
    
    init(canvasSize: PixelSize) {
        canvasViewSize = Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
        
        metalView.setDrawableSize(CGSize(
            width: canvasSize.width,
            height: canvasSize.height))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        canvasView.singleFingerPanEnabled = false
        
        canvasView.canvasContentView.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
        
        metalView.metalLayer.shouldRasterize = true
        metalView.metalLayer.rasterizationScale = 1
        
        let strokeGesture = BrushStrokeGestureRecognizer()
        strokeGesture.gestureDelegate = self
        canvasView.canvasContentView
            .addGestureRecognizer(strokeGesture)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    // MARK: Interface
    
    func drawTextureToCanvas(_ texture: MTLTexture) {
        layerRenderer.draw(
            texture: texture,
            to: metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension DrawingEditorCanvasVC: MovableCanvasViewDelegate {
    
    func contentSize(_ v: MovableCanvasView) -> Size {
        canvasViewSize
    }
    
    func minScale(_ v: MovableCanvasView) -> Scalar {
        minScaleLevel
    }
    
    func maxScale(_ v: MovableCanvasView) -> Scalar {
        maxScaleLevel
    }
    
    func onUpdateTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform
    ) {
        if transform.scale >= scalePixelateThreshold {
            metalView.layer.magnificationFilter = .nearest
            metalView.layer.minificationFilter = .nearest
        } else {
            metalView.layer.magnificationFilter = .linear
            metalView.layer.minificationFilter = .linear
        }
    }
    
}

extension DrawingEditorCanvasVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        delegate?.needsDrawLayer(self)
    }
    
}

extension DrawingEditorCanvasVC: BrushStrokeGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke() {
        delegate?.onBeginBrushStroke(self)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushStrokeGestureRecognizer.Stroke
    ) {
        delegate?.onUpdateBrushStroke(self, stroke)
    }
    
    func onEndBrushStroke() {
        delegate?.onEndBrushStroke(self)
    }
    
}
