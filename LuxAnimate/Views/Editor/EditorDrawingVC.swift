//
//  EditorDrawingVC.swift
//

import UIKit
import Metal

class EditorDrawingVC: UIViewController {
        
    private let canvasView = MovableCanvasView()
    private let metalView = MetalView()
    
    private let canvasViewSize: Size
    
    private let drawingRenderer: TestDrawingRenderer
    private let layerRenderer: MetalLayerTextureRenderer
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        drawing: Project.Drawing,
        drawingSize: Size
    ) {
        let viewportSize = Size(
            Double(projectManifest.metadata.viewportWidth),
            Double(projectManifest.metadata.viewportHeight))
            
        let viewportPixelSize = PixelSize(
            width: projectManifest.metadata.viewportWidth,
            height: projectManifest.metadata.viewportHeight)
        
        let url = FileUrlHelper().projectAssetURL(
            projectID: projectManifest.id,
            assetID: drawing.assets.full)
        
        let texture = try! JXLImageLoader.load(url: url)
        
        canvasViewSize = Size(
            viewportSize.width / 2,
            viewportSize.height / 2)
        
        drawingRenderer = TestDrawingRenderer(
            framebufferSize: viewportPixelSize,
            viewportSize: viewportSize,
            drawingSize: drawingSize,
            drawingTexture: texture)
        
        layerRenderer = MetalLayerTextureRenderer()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        render()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(canvasView)
        canvasView.pinEdges()
        canvasView.delegate = self
        
        canvasView.contentView.addSubview(metalView)
        metalView.pinEdges()
        metalView.delegate = self
    }
    
    // MARK: - Rendering
    
    private func render() {
        drawingRenderer.draw()
        
        layerRenderer.draw(
            texture: drawingRenderer.getFramebuffer(),
            to: metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension EditorDrawingVC: MovableCanvasViewDelegate {
    
    func contentSize(_ v: MovableCanvasView) -> Size {
        canvasViewSize
    }
    
    func minScale(_ v: MovableCanvasView) -> Scalar {
        0.1
    }
    
    func maxScale(_ v: MovableCanvasView) -> Scalar {
        10
    }
    
    func onUpdateTransform(
        _ v: MovableCanvasView,
        _ transform: MovableCanvasTransform
    ) {
        // TODO: adjust pixelation based on scale
    }
    
}

extension EditorDrawingVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        render()
    }
    
}
