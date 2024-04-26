//
//  DrawingEditorCanvasVC.swift
//

import UIKit
import Metal

private let minScaleLevel: Scalar = 0.1
private let maxScaleLevel: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

protocol DrawingEditorCanvasVCDelegate: AnyObject {
    func needsDrawLayer(_ vc: DrawingEditorCanvasVC)
}

class DrawingEditorCanvasVC: UIViewController {
    
    weak var delegate: DrawingEditorCanvasVCDelegate?
        
    let metalView = MetalView()
    
    private let canvasView = MovableCanvasView()
    
    private let canvasViewSize: Size
    
    // MARK: - Init
    
    init(drawingSize: PixelSize) {
        canvasViewSize = Size(
            Scalar(drawingSize.width),
            Scalar(drawingSize.height))
        
        metalView.setDrawableSize(CGSize(
            width: drawingSize.width,
            height: drawingSize.height))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        canvasView.fitCanvasToBounds(animated: false)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.clipsToBounds = true
        view.backgroundColor = .editorBackground
        
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        
        canvasView.canvasContentView.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
        
        metalView.metalLayer.shouldRasterize = true
        metalView.metalLayer.rasterizationScale = 1
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
