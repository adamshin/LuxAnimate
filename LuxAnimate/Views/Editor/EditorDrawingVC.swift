//
//  EditorDrawingVC.swift
//

import UIKit
import Metal

private let minScaleLevel: Scalar = 0.1
private let maxScaleLevel: Scalar = 30
private let scalePixelateThreshold: Scalar = 1.0

class EditorDrawingVC: UIViewController {
        
    private let canvasView = MovableCanvasView()
    private let metalView = MetalView()
    
    private let backButton = UIButton(type: .system)
    
    private let canvasViewSize: Size
    
    private let drawingRenderer: TestDrawingRenderer
    private let layerRenderer: MetalLayerTextureRenderer
    
    private let drawingTexture: MTLTexture
    
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
        
        drawingTexture = try! JXLTextureLoader.load(url: url)
        
        canvasViewSize = Size(
            viewportSize.width,
            viewportSize.height)
        
        drawingRenderer = TestDrawingRenderer(
            renderTargetSize: viewportPixelSize,
            viewportSize: viewportSize,
            drawingSize: drawingSize,
            drawingTexture: drawingTexture)
        
        layerRenderer = MetalLayerTextureRenderer()
        
        metalView.setDrawableSize(CGSize(viewportSize))
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
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
        
        view.addSubview(backButton)
        backButton.pinEdges(
            [.top, .leading],
            to: view.safeAreaLayoutGuide,
            padding: 16)
        
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = .systemFont(
            ofSize: 17, weight: .regular)
        backButton.addHandler { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    // MARK: - Rendering
    
    private func render() {
        drawingRenderer.draw()
        
        layerRenderer.draw(
            texture: drawingRenderer.renderTarget.texture,
            to: metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension EditorDrawingVC: MovableCanvasViewDelegate {
    
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

extension EditorDrawingVC: MetalViewDelegate {
    
    func draw(in layer: CAMetalLayer) {
        render()
    }
    
}
