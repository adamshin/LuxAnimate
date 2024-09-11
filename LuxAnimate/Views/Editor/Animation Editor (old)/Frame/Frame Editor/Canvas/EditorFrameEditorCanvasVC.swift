//
//  EditorFrameEditorCanvasVC.swift
//

import UIKit
import Metal

private let minScale: Scalar = 0.1
private let maxScale: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

@MainActor
protocol EditorFrameEditorCanvasVCDelegate: AnyObject {
    
    func onSelectUndo(_ vc: EditorFrameEditorCanvasVC)
    func onSelectRedo(_ vc: EditorFrameEditorCanvasVC)
    
}

class EditorFrameEditorCanvasVC: UIViewController {
    
    weak var delegate: EditorFrameEditorCanvasVCDelegate?
    
    private let metalView = MetalView()
    private let canvasView = MovableCanvasView()
    
    private let undoGesture = MultiFingerTapGestureRecognizer(touchCount: 2)
    private let redoGesture = MultiFingerTapGestureRecognizer(touchCount: 3)
    
    private let layerRenderer = MetalLayerTextureRenderer()
    
    private var canvasTexture: MTLTexture?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        canvasView.minScale = minScale
        canvasView.maxScale = maxScale
        
        canvasView.canvasContentView.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
        
        metalView.metalLayer.shouldRasterize = true
        metalView.metalLayer.rasterizationScale = 1
        
        canvasView.canvasContentView.addGestureRecognizer(undoGesture)
        canvasView.canvasContentView.addGestureRecognizer(redoGesture)
        undoGesture.addTarget(self, action: #selector(onUndoGesture))
        redoGesture.addTarget(self, action: #selector(onRedoGesture))
        
        setCanvasSize(PixelSize(width: 0, height: 0))
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    // MARK: - Handlers
    
    @objc private func onUndoGesture() {
        delegate?.onSelectUndo(self)
    }
    
    @objc private func onRedoGesture() {
        delegate?.onSelectRedo(self)
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
        metalView.setDrawableSize(CGSize(
            width: canvasSize.width,
            height: canvasSize.height))
        
        canvasView.canvasSize = canvasSize
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    func setCanvasTexture(_ texture: MTLTexture) {
        canvasTexture = texture
        drawCanvas()
    }
    
    func setEditingEnabled(_ enabled: Bool) {
        undoGesture.isEnabled = enabled
        redoGesture.isEnabled = enabled
    }
    
    func setSafeAreaReferenceView(_ view: UIView) {
        canvasView.setSafeAreaReferenceView(view)
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        canvasView.handleChangeSafeAreaReferenceViewFrame()
    }
    
    var canvasContentView: UIView {
        canvasView.canvasContentView
    }
    
}

// MARK: - Delegates

extension EditorFrameEditorCanvasVC: MovableCanvasViewDelegate {
    
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

extension EditorFrameEditorCanvasVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        drawCanvas()
    }
    
}
