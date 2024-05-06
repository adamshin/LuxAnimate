//
//  EditorDrawingCanvasVC.swift
//

import UIKit
import Metal

private let minScaleLevel: Scalar = 0.1
private let maxScaleLevel: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

protocol EditorDrawingCanvasVCDelegate: AnyObject {
    
}

class EditorDrawingCanvasVC: UIViewController {
    
    weak var delegate: EditorDrawingCanvasVCDelegate?
    
    weak var brushGestureDelegate: BrushGestureRecognizerGestureDelegate? {
        didSet {
            brushGesture.gestureDelegate = brushGestureDelegate
        }
    }
    
    private let metalView = MetalView()
    private let canvasView = MovableCanvasView()
    private let brushGesture = BrushGestureRecognizer()
    
    private let layerRenderer = MetalLayerTextureRenderer()
    
    private var canvasSize = PixelSize(width: 0, height: 0)
    private var canvasTexture: MTLTexture?
    
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
        
        canvasView.canvasContentView
            .addGestureRecognizer(brushGesture)
        
        setCanvasSize(PixelSize(width: 100, height: 100))
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    // MARK: - Canvas
    
    private func drawCanvas() {
        guard let canvasTexture else { return }
        
        layerRenderer.draw(
            texture: canvasTexture,
            to: metalView.metalLayer)
    }
    
    // MARK: - Interface
    
    func setCanvasSize(_ canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        metalView.setDrawableSize(CGSize(
            width: canvasSize.width,
            height: canvasSize.height))
        
        canvasView.handleChangeCanvasSize()
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    func setCanvasTexture(_ texture: MTLTexture) {
        canvasTexture = texture
        drawCanvas()
    }
    
    func setSafeAreaReferenceView(_ safeAreaReferenceView: UIView) {
        canvasView.setSafeAreaReferenceView(safeAreaReferenceView)
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        canvasView.handleChangeSafeAreaReferenceViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorDrawingCanvasVC: MovableCanvasViewDelegate {
    
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

extension EditorDrawingCanvasVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        drawCanvas()
    }
    
}
