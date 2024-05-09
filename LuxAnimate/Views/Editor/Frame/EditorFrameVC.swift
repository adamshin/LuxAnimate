//
//  EditorFrameVC.swift
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
    taperLength: 0.05,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlack

protocol EditorFrameVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: EditorFrameVC)
    func onSelectUndo(_ vc: EditorFrameVC)
    func onSelectRedo(_ vc: EditorFrameVC)
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize)
    
    func currentProjectManifest(
        _ vc: EditorFrameVC
    ) -> Project.Manifest?
    
}

class EditorFrameVC: UIViewController {
    
    weak var delegate: EditorFrameVCDelegate?
    
    private let contentVC = EditorFrameContentVC()
    
    private let projectID: String
    private let drawingSize: PixelSize
    
    private var currentFrameIndex: Int?
    
    private var drawingID: String?
    private var isEditingEnabled = false
    
    private let brushEngine: BrushEngine
    private var brushMode: BrushEngine.BrushMode = .brush
    
    private let brush = try! Brush(
        configuration: brushConfig)
    
    private let drawingRenderer: DrawingEditorFrameRenderer
    
    private let fileUrlHelper = FileUrlHelper()
    
    private let frameLoadingQueue = DispatchQueue(
        label: "EditorFrameVC.frameLoadingQueue",
        qos: .background)
    
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
        contentVC.toolbarVC.delegate = self
        
        addChild(contentVC, to: view)
        
        contentVC.canvasVC.setCanvasSize(drawingSize)
    }
    
    // MARK: - Drawings
    
    private func showDrawing(
        _ drawing: Project.Drawing,
        forceReload: Bool
    ) {
        if drawingID == drawing.id, !forceReload {
            return
        }
        
        brushEngine.endStroke()
        
        drawingID = drawing.id
        isEditingEnabled = false
        
        loadAndDisplayFrame(drawing: drawing)
    }
    
    private func showNoDrawing() {
        brushEngine.endStroke()
        
        drawingID = nil
        isEditingEnabled = false
        
        displayEmptyFrame()
    }
    
    private func loadAndDisplayFrame(
        drawing: Project.Drawing
    ) {
        loadAndDisplayPreviewImage(drawing: drawing) {
            self.loadAndDisplayFullImage(drawing: drawing)
        }
    }
    
    private func loadAndDisplayPreviewImage(
        drawing: Project.Drawing,
        completion: @escaping () -> Void
    ) {
        frameLoadingQueue.async {
            guard self.drawingID == drawing.id else { return }
            
            let assetURL = self.fileUrlHelper.projectAssetURL(
                projectID: self.projectID,
                assetID: drawing.assetIDs.medium)
            
            let texture = try! JXLTextureLoader.load(url: assetURL)
            
            DispatchQueue.main.async {
                guard self.drawingID == drawing.id else { return }
                
                self.drawingRenderer.draw(
                    drawingTexture: texture)
                
                self.contentVC.canvasVC.setCanvasTexture(
                    self.drawingRenderer.texture)
                
                self.loadAndDisplayFullImage(drawing: drawing)
            }
        }
    }
    
    private func loadAndDisplayFullImage(
        drawing: Project.Drawing
    ) {
        frameLoadingQueue.async {
            guard self.drawingID == drawing.id else { return }
            
            let assetURL = self.fileUrlHelper.projectAssetURL(
                projectID: self.projectID,
                assetID: drawing.assetIDs.full)
            
            let texture = try! JXLTextureLoader.load(url: assetURL)
            
            DispatchQueue.main.async {
                guard self.drawingID == drawing.id else { return }
                
                self.brushEngine.setCanvasContents(texture)
                self.render()
                
                self.isEditingEnabled = true
            }
        }
    }
    
    private func displayEmptyFrame() {
        let texture = emptyTexture(size: drawingSize)
        brushEngine.setCanvasContents(texture)
        render()
    }
    
    private func emptyTexture(size: PixelSize) -> MTLTexture {
        let byteCount = size.width * size.height * 4
        let data = Data(repeating: 0, count: byteCount)
        
        return try! TextureCreator.createTexture(
            imageData: data,
            width: size.width,
            height: size.height,
            mipMapped: false)
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
    
    func showFrame(
        at frameIndex: Int,
        forceReload: Bool = false
    ) {
        currentFrameIndex = frameIndex
        
        guard let projectManifest =
            delegate?.currentProjectManifest(self)
        else { return }
        
        let animationLayer = projectManifest.content.animationLayer
        
        if let drawing = drawingForFrame(
            drawings: animationLayer.drawings,
            frameIndex: frameIndex)
        {
            showDrawing(drawing, forceReload: forceReload)
        } else {
            showNoDrawing()
        }
    }
    
    func handleUpdateFrame(at frameIndex: Int) {
        if currentFrameIndex == frameIndex {
            showFrame(at: frameIndex, forceReload: true)
        }
    }
    
    func reloadFrame() {
        guard let currentFrameIndex else { return }
        showFrame(at: currentFrameIndex, forceReload: true)
    }
    
    func setPlaying(_ playing: Bool) {
        contentVC.canvasVC.setEditingEnabled(!playing)
    }
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        contentVC.setBottomInsetView(bottomInsetView)
    }
    
    func handleChangeBottomInsetViewFrame() {
        contentVC.handleChangeBottomInsetViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorFrameVC: EditorFrameCanvasVCDelegate {
    
    func onSelectUndo(_ vc: EditorFrameCanvasVC) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ vc: EditorFrameCanvasVC) {
        delegate?.onSelectRedo(self)
    }
    
    
    func onBeginBrushStroke(quickTap: Bool) {
        guard isEditingEnabled else { return }
        
        let scale = contentVC.toolOverlayVC.size
        let smoothingLevel = contentVC.toolOverlayVC.smoothing
        
        brushEngine.beginStroke(
            brush: brush,
            brushMode: brushMode,
            color: brushColor,
            scale: scale,
            quickTap: quickTap,
            smoothingLevel: smoothingLevel)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        guard isEditingEnabled else { return }
        
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        guard isEditingEnabled else { return }
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke() {
        guard isEditingEnabled else { return }
        brushEngine.cancelStroke()
    }
    
}

extension EditorFrameVC: EditorFrameToolbarVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectBack(self)
    }
    func onSelectBrush(_ vc: EditorFrameToolbarVC) {
        brushMode = .brush
    }
    func onSelectErase(_ vc: EditorFrameToolbarVC) {
        brushMode = .erase
    }
    func onSelectUndo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectRedo(self)
    }
    
}

extension EditorFrameVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        render()
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
        applyBrushStrokeEdit()
    }
    
}

// MARK: - Frame Search

private func drawingForFrame(
    drawings: [Project.Drawing],
    frameIndex: Int
) -> Project.Drawing? {
    
    guard !drawings.isEmpty else { return nil }
    
    let drawings = drawings.sorted {
        $0.frameIndex < $1.frameIndex
    }
    
    var left = 0
    var right = drawings.count - 1
    
    while left <= right {
        let mid = (left + right) / 2
        
        if drawings[mid].frameIndex == frameIndex {
            return drawings[mid]
        } else if drawings[mid].frameIndex < frameIndex {
            left = mid + 1
        } else {
            right = mid - 1
        }
    }
    
    if right < 0 {
        return nil
    }
    
    return drawings[right]
}
