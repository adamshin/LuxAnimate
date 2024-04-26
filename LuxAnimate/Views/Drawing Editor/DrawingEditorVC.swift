//
//  DrawingEditorVC.swift
//

import UIKit

private let brushConfig = Brush.Configuration(
    stampTextureName: "brush1.png",
    stampSize: 100,
    stampSpacing: 0.0,
    stampAlpha: 1,
    pressureScaling: 0,
    taperLength: 0,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlue
private let brushScale: Double = 0.2

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
    
    private let drawingID: String
    private let canvasSize: PixelSize
    private let brushEngine: BrushEngine
    
    private let drawingRenderer: DrawingEditorFrameRenderer
    
    private let brush = try! Brush(
        configuration: brushConfig)
    
    // MARK: - Init
    
    init(
        projectID: String,
        drawing: Project.Drawing
    ) {
        canvasVC = DrawingEditorCanvasVC(
            canvasSize: drawing.size)
        
        toolFrameVC = DrawingEditorToolFrameVC()
        
        drawingID = drawing.id
        canvasSize = drawing.size
        brushEngine = BrushEngine(canvasSize: drawing.size)
        
        drawingRenderer = DrawingEditorFrameRenderer(
            drawingSize: drawing.size,
            backgroundColor: .white)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        brushEngine.delegate = self
        
        // Instantiate canvas
        let assetURL = FileUrlHelper().projectAssetURL(
            projectID: projectID,
            assetID: drawing.assetIDs.full)
        
        let assetTexture = try! JXLTextureLoader.load(url: assetURL)
        
        brushEngine.setCanvasContents(assetTexture)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.clipsToBounds = true
        
        addChild(canvasVC, to: view)
        addChild(toolFrameVC, to: view)
        
        canvasVC.delegate = self
        toolFrameVC.delegate = self
    }
    
    // MARK: - Logic
    
    private func saveEdit() {
        do {
            let imageData = try TextureDataReader
                .read(brushEngine.canvasTexture)
            
            delegate?.onEditDrawing(
                self,
                drawingID: drawingID,
                imageData: imageData,
                imageSize: canvasSize)
            
        } catch { }
    }
    
    // MARK: - Rendering
    
    private func render() {
        let drawingTexture = brushEngine.canvasTexture
        drawingRenderer.draw(drawingTexture: drawingTexture)
        
        canvasVC.drawTextureToCanvas(drawingRenderer.texture)
    }
    
}

// MARK: - Delegates

extension DrawingEditorVC: DrawingEditorCanvasVCDelegate {
    
    func onBeginBrushStroke(
        _ vc: DrawingEditorCanvasVC
    ) {
        brushEngine.beginStroke(
            brush: brush,
            color: brushColor,
            scale: brushScale,
            smoothingLevel: 0.2)
    }
    
    func onUpdateBrushStroke(
        _ vc: DrawingEditorCanvasVC,
        _ stroke: BrushStrokeGestureRecognizer.Stroke
    ) {
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke(
        _ vc: DrawingEditorCanvasVC
    ) {
        brushEngine.endStroke()
    }
    
    
    func needsDrawLayer(
        _ vc: DrawingEditorCanvasVC
    ) {
        render()
    }
    
}

extension DrawingEditorVC: DrawingEditorToolFrameVCDelegate {
    
    func onSelectBack(_ vc: DrawingEditorToolFrameVC) {
        dismiss(animated: true)
    }
    
}

extension DrawingEditorVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        render()
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        saveEdit()
    }
    
}
