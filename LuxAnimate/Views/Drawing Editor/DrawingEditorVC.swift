//
//  DrawingEditorVC.swift
//

import UIKit

private let brushConfig = Brush.Configuration(
    stampTextureName: "brush1.png",
    stampSize: 50,
    stampSpacing: 0.0,
    stampAlpha: 1,
    pressureScaling: 0.5,
    taperLength: 0.05,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlack

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
        canvasSize: PixelSize,
        drawing: Project.Drawing
    ) {
        canvasVC = DrawingEditorCanvasVC(
            canvasSize: canvasSize)
        
        toolFrameVC = DrawingEditorToolFrameVC()
        
        drawingID = drawing.id
        self.canvasSize = canvasSize
        
        brushEngine = BrushEngine(canvasSize: canvasSize)
        
        drawingRenderer = DrawingEditorFrameRenderer(
            drawingSize: canvasSize,
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
    
    private func clearCanvas() {
        do {
            let byteCount = canvasSize.width * canvasSize.height * 4
            let imageData = Data(repeating: 0, count: byteCount)
            
            let texture = try TextureCreator.createTexture(
                imageData: imageData,
                width: canvasSize.width,
                height: canvasSize.height,
                mipMapped: false)
            
            brushEngine.setCanvasContents(texture)
            render()
            
            delegate?.onEditDrawing(
                self,
                drawingID: drawingID,
                imageData: imageData,
                imageSize: canvasSize)
            
        } catch { }
    }
    
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
        toolFrameVC.hidePopups()
        
        let scale = toolFrameVC.brushSize
        let smoothingLevel = toolFrameVC.smoothing
        
        brushEngine.beginStroke(
            brush: brush,
            brushMode: .brush,
            color: brushColor,
            scale: scale,
            smoothingLevel: smoothingLevel)
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
    
    func onSelectClear(_ vc: DrawingEditorToolFrameVC) {
        clearCanvas()
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
