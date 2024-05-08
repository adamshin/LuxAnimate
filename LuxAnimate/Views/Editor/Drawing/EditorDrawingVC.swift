//
//  EditorDrawingVC.swift
//

import UIKit
import Metal

// This view controller should contain logic for loading
// and displaying the contents of a single frame. It should
// coordinate with the frame cache system -- maybe that lives
// a layer up in the EditorVC?

// At any moment, the user may switch frames. We need to display
// the frame's content quickly. The process should look like this:

// 1) Display a cached preview image if one exists.
// 2) Load the contents of each layer at medium resolution.
// 3) Load the contents of the active layer at high resolution.
//    (at this point, editing is possible)

// There may be multiple caching systems at play here. We
// need to render and cache preview images a few frames
// ahead and behind the current frame. We may also want to
// render some very low-res preview images across the whole
// timeline, in case the user scrubs fast. Maybe these can
// be small enough to all stay in memory. Or maybe they need
// to be written to disk. We also will need to render frames
// to video for playback. Depending how fast this is, maybe
// it can be done in realtime or near-realtime? More likely,
// we'll need to prerender these video segments to disk. Too
// big to keep in memory at once.

// Maybe editing tools should live inside here as well.
// Probably easier than propagating all that interaction
// up to the EditorVC.

// TODO: Factor out the tool system. Maybe it should live
// in nested view controllers?

private let brushConfig = Brush.Configuration(
    stampTextureName: "brush1.png",
    stampSize: 50,
    stampSpacing: 0.0,
    stampAlpha: 1,
    pressureScaling: 0.5,
    taperLength: 1.0,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlack

protocol EditorDrawingVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: EditorDrawingVC)
    
    func onEditDrawing(
        _ vc: EditorDrawingVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize)
    
}

class EditorDrawingVC: UIViewController {
    
    weak var delegate: EditorDrawingVCDelegate?
    
    private let contentVC = EditorDrawingContentVC()
    
    private let projectID: String
    private let drawingSize: PixelSize
    
    private var drawingID: String?
    
    private let brushEngine: BrushEngine
    private let drawingRenderer: DrawingEditorFrameRenderer
    
    private let brush = try! Brush(
        configuration: brushConfig)
    
    // MARK: - Init
    
    init(
        projectID: String,
        animationLayer: Project.AnimationLayer
    ) {
        self.projectID = projectID
        drawingSize = animationLayer.size
        
        brushEngine = BrushEngine(canvasSize: drawingSize)
        
        drawingRenderer = DrawingEditorFrameRenderer(
            drawingSize: drawingSize,
            backgroundColor: .white)
        
        super.init(nibName: nil, bundle: nil)
        
        brushEngine.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentVC.canvasVC.delegate = self
        contentVC.topBarVC.delegate = self
        
        addChild(contentVC, to: view)
        
        contentVC.canvasVC.setCanvasSize(drawingSize)
        
        contentVC.toolOverlayVC.size = 0.25
        contentVC.toolOverlayVC.smoothing = 0
    }
    
    // MARK: - Editing
    
    private func applyBrushStrokeEdit() {
        guard let drawingID else { return }
        
        do {
            let imageData = try TextureDataReader
                .read(brushEngine.canvasTexture)
            
            let imageSize = brushEngine.canvasSize
            
            delegate?.onEditDrawing(
                self,
                drawingID: drawingID,
                imageData: imageData,
                imageSize: imageSize)
            
        } catch { }
    }
    
    // MARK: - Rendering
    
    private func render() {
        drawingRenderer.draw(
            drawingTexture: brushEngine.canvasTexture)
        
        contentVC.canvasVC.setCanvasTexture(
            drawingRenderer.texture)
    }
    
    // MARK: - Interface
    
    func showDrawing(_ drawing: Project.Drawing) {
        brushEngine.endStroke()
        
        drawingID = drawing.id
        
        let assetURL = FileUrlHelper().projectAssetURL(
            projectID: projectID,
            assetID: drawing.assetIDs.full)
        
        let assetTexture = try! JXLTextureLoader.load(
            url: assetURL)
        
        brushEngine.setCanvasContents(assetTexture)
        
        render()
    }
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        contentVC.setBottomInsetView(bottomInsetView)
    }
    
    func handleChangeBottomInsetViewFrame() {
        contentVC.handleChangeBottomInsetViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorDrawingVC: EditorDrawingCanvasVCDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        let scale = contentVC.toolOverlayVC.size
        let smoothingLevel = contentVC.toolOverlayVC.smoothing
        
        brushEngine.beginStroke(
            brush: brush,
            brushMode: .brush,
            color: brushColor,
            scale: scale,
            quickTap: quickTap,
            smoothingLevel: smoothingLevel)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke() {
        brushEngine.cancelStroke()
    }
    
}

extension EditorDrawingVC: EditorDrawingTopBarVCDelegate {
    
    func onSelectBack(_ vc: EditorDrawingTopBarVC) {
        delegate?.onSelectBack(self)
    }
    
    func onSelectBrush(_ vc: EditorDrawingTopBarVC) { }
    
}

extension EditorDrawingVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        render()
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        applyBrushStrokeEdit()
    }
    
}
