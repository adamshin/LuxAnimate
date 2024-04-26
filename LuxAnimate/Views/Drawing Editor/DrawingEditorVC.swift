//
//  DrawingEditorVC.swift
//

import UIKit

protocol DrawingEditorVCDelegate: AnyObject {
    
    func onEditDrawing(
        _ vc: DrawingEditorVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize)
    
}

class DrawingEditorVC: UIViewController {
    
    weak var delegate: DrawingEditorVCDelegate?
    
    private let canvasVC: DrawingEditorCanvasVC
    private let toolFrameVC: DrawingEditorToolFrameVC
    
    private let drawingRenderer: DrawingEditorFrameRenderer
    private let layerRenderer: MetalLayerTextureRenderer
    
    private let drawingTexture: MTLTexture
    
    // MARK: - Init
    
    init(
        projectID: String,
        drawing: Project.Drawing
    ) {
        canvasVC = DrawingEditorCanvasVC(
            drawingSize: drawing.size)
        
        toolFrameVC = DrawingEditorToolFrameVC()
        
        drawingRenderer = DrawingEditorFrameRenderer(
            drawingSize: drawing.size,
            backgroundColor: .white)
        
        layerRenderer = MetalLayerTextureRenderer()
        
        let assetURL = FileUrlHelper().projectAssetURL(
            projectID: projectID,
            assetID: drawing.assetIDs.full)
        
        drawingTexture = try! JXLTextureLoader.load(url: assetURL)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRendering()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.clipsToBounds = true
        
        addChild(canvasVC, to: view)
        addChild(toolFrameVC, to: view)
        
        canvasVC.delegate = self
        toolFrameVC.delegate = self
    }
    
    private func setupRendering() {
        drawingRenderer.setDrawingTexture(drawingTexture)
    }
    
    // MARK: - Rendering
    
    private func render() {
        drawingRenderer.draw(activeDrawingTexture: nil)
        
        layerRenderer.draw(
            texture: drawingRenderer.renderTarget.texture,
            to: canvasVC.metalView.metalLayer)
    }
    
}

// MARK: - Delegates

extension DrawingEditorVC: DrawingEditorCanvasVCDelegate {
    
    func needsDrawLayer(_ vc: DrawingEditorCanvasVC) {
        render()
    }
    
}

extension DrawingEditorVC: DrawingEditorToolFrameVCDelegate {
    
    func onSelectBack(_ vc: DrawingEditorToolFrameVC) {
        dismiss(animated: true)
    }
    
}
