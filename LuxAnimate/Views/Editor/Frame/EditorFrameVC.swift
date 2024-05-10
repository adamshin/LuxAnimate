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
    
    private let brush = try! Brush(configuration: brushConfig)
    
    private let frameRenderer: EditorFrameRenderer
    
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
        
        frameRenderer = EditorFrameRenderer(
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
        drawing: Project.Drawing?,
        prevDrawing: Project.Drawing?,
        nextDrawing: Project.Drawing?,
        forceReload: Bool
    ) {
        if drawingID == drawing?.id, !forceReload {
            return
        }
        
        brushEngine.endStroke()
        
        drawingID = drawing?.id
        isEditingEnabled = false
        
        loadAndDisplayFrame(
            drawing: drawing,
            prevDrawing: prevDrawing,
            nextDrawing: nextDrawing)
    }
    
    private func loadAndDisplayFrame(
        drawing: Project.Drawing?,
        prevDrawing: Project.Drawing?,
        nextDrawing: Project.Drawing?
    ) {
        frameRenderer.drawingTexture = nil
        frameRenderer.prevDrawingTexture = nil
        frameRenderer.nextDrawingTexture = nil
        
        loadAndDisplayPreviewImage(
            drawing: drawing,
            prevDrawing: prevDrawing,
            nextDrawing: nextDrawing
        ) {
            self.loadAndDisplayFullImage(drawing: drawing)
        }
    }
    
    private func loadAndDisplayPreviewImage(
        drawing: Project.Drawing?,
        prevDrawing: Project.Drawing?,
        nextDrawing: Project.Drawing?,
        completion: @escaping () -> Void
    ) {
        frameLoadingQueue.async {
            guard self.drawingID == drawing?.id else { return }
            
            var drawingTexture: MTLTexture?
            if let drawing {
                let assetURL = self.fileUrlHelper.projectAssetURL(
                    projectID: self.projectID,
                    assetID: drawing.assetIDs.medium)
                
                drawingTexture = try? JXLTextureLoader.load(url: assetURL)
            }
            
            self.frameLoadingQueue.async {
                guard self.drawingID == drawing?.id else { return }
                
                var prevDrawingTexture: MTLTexture?
                if let prevDrawing {
                    let assetURL = self.fileUrlHelper.projectAssetURL(
                        projectID: self.projectID,
                        assetID: prevDrawing.assetIDs.medium)
                    
                    prevDrawingTexture = try? JXLTextureLoader.load(url: assetURL)
                }
                
                var nextDrawingTexture: MTLTexture?
                if let nextDrawing {
                    let assetURL = self.fileUrlHelper.projectAssetURL(
                        projectID: self.projectID,
                        assetID: nextDrawing.assetIDs.medium)
                    
                    nextDrawingTexture = try? JXLTextureLoader.load(url: assetURL)
                }
                
                DispatchQueue.main.async {
                    guard self.drawingID == drawing?.id else { return }
                    
                    self.frameRenderer.prevDrawingTexture = prevDrawingTexture
                    self.frameRenderer.nextDrawingTexture = nextDrawingTexture
                    self.draw()
                }
            }
            
            DispatchQueue.main.async {
                guard self.drawingID == drawing?.id else { return }
                
                self.frameRenderer.drawingTexture = drawingTexture
                self.draw()
                
                self.loadAndDisplayFullImage(drawing: drawing)
            }
        }
    }
    
    private func loadAndDisplayFullImage(
        drawing: Project.Drawing?
    ) {
        frameLoadingQueue.async {
            guard self.drawingID == drawing?.id else { return }
            
            var drawingTexture: MTLTexture?
            if let drawing {
                let assetURL = self.fileUrlHelper.projectAssetURL(
                    projectID: self.projectID,
                    assetID: drawing.assetIDs.full)
                
                drawingTexture = try? JXLTextureLoader.load(url: assetURL)
            }
            
            DispatchQueue.main.async {
                guard self.drawingID == drawing?.id else { return }
                
                self.frameRenderer.drawingTexture = drawingTexture
                self.draw()
                
                if let drawingTexture {
                    self.brushEngine.setCanvasContents(drawingTexture)
                }
                
                self.isEditingEnabled = drawing != nil
            }
        }
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
    
    private func draw() {
        frameRenderer.draw()
        contentVC.canvasVC.setCanvasTexture(
            frameRenderer.renderTarget)
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
        
        let drawing = drawingForFrame(
            drawings: animationLayer.drawings,
            frameIndex: frameIndex)
        let prevDrawing = drawingBefore(
            drawings: animationLayer.drawings,
            frameIndex: frameIndex)
        let nextDrawing = drawingAfter(
            drawings: animationLayer.drawings,
            frameIndex: frameIndex)
        
        showDrawing(
            drawing: drawing,
            prevDrawing: prevDrawing,
            nextDrawing: nextDrawing,
            forceReload: forceReload)
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
    
    func setOnionSkinOn(_ isOnionSkinOn: Bool) {
        frameRenderer.isOnionSkinOn = isOnionSkinOn
        draw()
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
    func onSetTraceOn(_ vc: EditorFrameToolbarVC, on: Bool) {
        frameRenderer.isOnionSkinOn = on
        draw()
    }
    
}

extension EditorFrameVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
        frameRenderer.drawingTexture = brushEngine.canvasTexture
        draw()
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
    
    let sortedDrawings = drawings.sorted {
        $0.frameIndex < $1.frameIndex
    }
    return sortedDrawings.last {
        $0.frameIndex <= frameIndex
    }
}

private func drawingBefore(
    drawings: [Project.Drawing],
    frameIndex: Int
) -> Project.Drawing? {
    
    let sortedDrawings = drawings.sorted {
        $0.frameIndex < $1.frameIndex
    }
    return sortedDrawings.last {
        $0.frameIndex < frameIndex
    }
}

private func drawingAfter(
    drawings: [Project.Drawing],
    frameIndex: Int
) -> Project.Drawing? {
    
    let sortedDrawings = drawings.sorted {
        $0.frameIndex < $1.frameIndex
    }
    return sortedDrawings.first {
        $0.frameIndex > frameIndex
    }
}
