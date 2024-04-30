//
//  EditorCanvasVC.swift
//

import UIKit
import Metal

private let minScaleLevel: Scalar = 0.1
private let maxScaleLevel: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

protocol EditorCanvasVCDelegate: AnyObject {
    
    func canvasBoundsReferenceView(_ vc: EditorCanvasVC) -> UIView?
    
    func needsDrawCanvas(_ vc: EditorCanvasVC)
    
}

class EditorCanvasVC: UIViewController {
    
    weak var delegate: EditorCanvasVCDelegate?
    
    weak var brushGestureDelegate: BrushGestureRecognizerGestureDelegate? {
        didSet {
            strokeGesture.gestureDelegate = brushGestureDelegate
        }
    }
        
    private let metalView = MetalView()
    private let canvasView = MovableCanvasView()
    private let strokeGesture = BrushGestureRecognizer()
    
//    private let layerRenderer = MetalLayerTextureRenderer()
    
    private var canvasSize = PixelSize(width: 0, height: 0)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        canvasView.singleFingerPanEnabled = false
        
        canvasView.canvasContentView.backgroundColor = .white
//        canvasView.canvasContentView.addSubview(metalView)
//        metalView.pinEdges()
//        metalView.delegate = self
        
        metalView.metalLayer.shouldRasterize = true
        metalView.metalLayer.rasterizationScale = 1
        
        canvasView.canvasContentView
            .addGestureRecognizer(strokeGesture)
        
        setCanvasSize(PixelSize(width: 1920, height: 1080))
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    // MARK: - Interface
    
    func setCanvasSize(_ canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        metalView.setDrawableSize(CGSize(
            width: canvasSize.width,
            height: canvasSize.height))
        
        canvasView.setNeedsCanvasSizeUpdate()
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    func handleUpdateBoundsReferenceView() {
        canvasView.handleUpdateBoundsReferenceView()
    }
    
    func drawTextureToCanvas(_ texture: MTLTexture) {
//        layerRenderer.draw(
//            texture: texture,
//            to: metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension EditorCanvasVC: MovableCanvasViewDelegate {
    
    func canvasSize(_ v: MovableCanvasView) -> Size {
        Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
    }
    
    func minScale(_ v: MovableCanvasView) -> Scalar {
        minScaleLevel
    }
    
    func maxScale(_ v: MovableCanvasView) -> Scalar {
        maxScaleLevel
    }
    
    func canvasBoundsReferenceView(_ v: MovableCanvasView) -> UIView? {
        delegate?.canvasBoundsReferenceView(self)
    }
    
    func onUpdateCanvasTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform
    ) {
        if transform.scale > scalePixelateThreshold {
            metalView.layer.magnificationFilter = .nearest
            metalView.layer.minificationFilter = .nearest
        } else {
            metalView.layer.magnificationFilter = .linear
            metalView.layer.minificationFilter = .linear
        }
    }
    
}

extension EditorCanvasVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        delegate?.needsDrawCanvas(self)
    }
    
}
