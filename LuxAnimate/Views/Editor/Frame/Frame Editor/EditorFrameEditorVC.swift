//
//  EditorFrameEditorVC.swift
//

import UIKit
import Metal

private let brushConfig = Brush.Configuration(
    stampTextureName: "brush1.png",
    stampSize: 50,
    stampSpacing: 0.0,
    stampAlpha: 1,
    pressureScaling: 0.5,
    taperLength: 0.05,
    taperRoundness: 1.0)

private let brushColor: Color = .brushBlack

private let onionSkinCount = 5

protocol EditorFrameEditorVCDelegate: AnyObject {
    
    func onSelectUndo(_ vc: EditorFrameEditorVC)
    func onSelectRedo(_ vc: EditorFrameEditorVC)
    
    func onEditDrawing(
        _ vc: EditorFrameEditorVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize)
    
}

class EditorFrameEditorVC: UIViewController {
    
    weak var delegate: EditorFrameEditorVCDelegate?
    
    private let canvasVC = EditorFrameEditorCanvasVC()
    
    private let projectID: String
    private let projectViewportSize: PixelSize
    private let drawingSize: PixelSize
    
    private var projectManifest: Project.Manifest?
    private var focusedFrameIndex = 0
    private var isOnionSkinOn = false
    
    private var activeDrawingID: String?
    
    private var frameScene: FrameScene?
    private var prevOnionSkinDrawingIDs: [String] = []
    private var nextOnionSkinDrawingIDs: [String] = []
    
    private var isEditingEnabled = true
    private var isActiveDrawingLoaded = false
    
    private var needsDraw = false
    
    private let assetLoader: EditorFrameAssetLoader
    
    private let activeDrawingRenderer: EditorFrameActiveDrawingRenderer
    private let frameSceneRenderer: EditorFrameSceneRenderer
    
    private let brushEngine: BrushEngine
    private var brushMode: BrushEngine.BrushMode = .brush
    private let brush = try! Brush(configuration: brushConfig)
    
    private let displayLink = WrappedDisplayLink()
    
    // MARK: - Init
    
    init(
        projectID: String,
        projectViewportSize: PixelSize,
        drawingSize: PixelSize
    ) {
        self.projectID = projectID
        self.projectViewportSize = projectViewportSize
        self.drawingSize = drawingSize
        
        assetLoader = EditorFrameAssetLoader(
            projectID: projectID)
        
        activeDrawingRenderer = EditorFrameActiveDrawingRenderer(
            drawingSize: drawingSize)
        
        frameSceneRenderer = EditorFrameSceneRenderer(
            viewportSize: projectViewportSize)
        
        brushEngine = BrushEngine(canvasSize: drawingSize)
        
        super.init(nibName: nil, bundle: nil)
        
        displayLink.setCallback { [weak self] in
            self?.onFrame()
        }
        
        assetLoader.delegate = self
        activeDrawingRenderer.delegate = self
        frameSceneRenderer.delegate = self
        brushEngine.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasVC.delegate = self
        addChild(canvasVC, to: view)
        
        canvasVC.setCanvasSize(projectViewportSize)
    }
    
    // MARK: - Frame
    
    @objc private func onFrame() {
        brushEngine.onFrame()
        
        if needsDraw {
            needsDraw = false
            draw()
        }
    }
    
    // MARK: - Frame Data
    
    private func updateFrameData() {
        brushEngine.endStroke()
        
        // TODO: Factor this code into a helper object?
        guard let projectManifest else { return }
        
        let onionSkinPrevCount = isOnionSkinOn ? onionSkinCount : 0
        let onionSkinNextCount = isOnionSkinOn ? onionSkinCount : 0
        
        // Calculate drawing IDs
        let drawings = projectManifest
            .content.animationLayer.drawings
        
        let drawingsForFrameResult = Self.drawingsForFrame(
            drawings: drawings,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinPrevCount: onionSkinPrevCount,
            onionSkinNextCount: onionSkinNextCount)
        
        activeDrawingID = drawingsForFrameResult.activeDrawing?.id
        
        prevOnionSkinDrawingIDs = drawingsForFrameResult
            .prevOnionSkinDrawings.map { $0.id }
        
        nextOnionSkinDrawingIDs = drawingsForFrameResult
            .nextOnionSkinDrawings.map { $0.id }
        
        // Generate frame scene
        let frameScene = FrameSceneGenerator.generate(
            projectManifest: projectManifest,
            frameIndex: focusedFrameIndex)
        
        self.frameScene = frameScene
        
        // Create list of drawings
        var drawingsToLoad: [Project.Drawing] = []
        
        let drawingsFromFrameScene = Self.drawings(from: frameScene)
        drawingsToLoad.append(contentsOf: drawingsFromFrameScene)
        
        drawingsToLoad.append(
            contentsOf: drawingsForFrameResult.prevOnionSkinDrawings)
        drawingsToLoad.append(
            contentsOf: drawingsForFrameResult.nextOnionSkinDrawings)
        
        // Load assets
        isActiveDrawingLoaded = false
        
        assetLoader.loadAssets(
            drawings: drawingsToLoad,
            activeDrawingID: activeDrawingID)
    }
    
    private struct DrawingsForFrameResult {
        var activeDrawing: Project.Drawing?
        var prevOnionSkinDrawings: [Project.Drawing]
        var nextOnionSkinDrawings: [Project.Drawing]
    }
    
    private static func drawingsForFrame(
        drawings: [Project.Drawing],
        focusedFrameIndex: Int,
        onionSkinPrevCount: Int,
        onionSkinNextCount: Int
    ) -> DrawingsForFrameResult {
        
        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let activeDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= focusedFrameIndex
        }
        
        var activeDrawing: Project.Drawing?
        var prevOnionSkinDrawings: [Project.Drawing] = []
        var nextOnionSkinDrawings: [Project.Drawing] = []
        
        if let activeDrawingIndex {
            activeDrawing = sortedDrawings[activeDrawingIndex]
            
            var prevDrawingIndex = activeDrawingIndex
            for _ in 0 ..< onionSkinPrevCount {
                prevDrawingIndex -= 1
                if sortedDrawings.indices.contains(prevDrawingIndex) {
                    let drawing = sortedDrawings[prevDrawingIndex]
                    prevOnionSkinDrawings.append(drawing)
                }
            }
            
            var nextDrawingIndex = activeDrawingIndex
            for _ in 0 ..< onionSkinNextCount {
                nextDrawingIndex += 1
                if sortedDrawings.indices.contains(nextDrawingIndex) {
                    let drawing = sortedDrawings[nextDrawingIndex]
                    nextOnionSkinDrawings.append(drawing)
                }
            }
        }
        
        return DrawingsForFrameResult(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
    }
    
    private static func drawings(
        from frameScene: FrameScene
    ) -> [Project.Drawing] {
        
        var result: [Project.Drawing] = []
        
        for layer in frameScene.layers {
            switch layer {
            case .drawing(let drawingLayer):
                result.append(drawingLayer.drawing)
            }
        }
        return result
    }
    
    // MARK: - Editing
    
    private func applyBrushStrokeEdit() {
        // TODO: This will trigger a reload of the full active drawing
        // texture, which is unnecessary. We need to figure out how to
        // avoid reloading. Probably by generating a full asset ID here,
        // and copying the brush engine canvas texture into our asset
        // loader cache.
        
//        guard let activeDrawingID else { return }
//        
//        do {
//            let imageData = try TextureDataReader
//                .read(brushEngine.canvasTexture)
//            
//            let imageSize = brushEngine.canvasSize
//            
//            delegate?.onEditDrawing(
//                self,
//                drawingID: activeDrawingID,
//                imageData: imageData,
//                imageSize: imageSize)
//            
//        } catch { }
    }
    
    // MARK: - Rendering
    
    private func draw() {
        guard assetLoader.hasLoadedAssetsForAllDrawings()
        else { return }
        
        activeDrawingRenderer.draw()
        frameSceneRenderer.draw()
        
        canvasVC.setCanvasTexture(
            frameSceneRenderer.renderTarget)
    }
    
    // MARK: - Editing
    
    private func setEditingEnabled(_ enabled: Bool) {
        isEditingEnabled = enabled
        canvasVC.setEditingEnabled(enabled)
    }
    
    // MARK: - Interface
    
    func setProjectManifest(_ projectManifest: Project.Manifest) {
        self.projectManifest = projectManifest
        updateFrameData()
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        guard focusedFrameIndex != index else { return }
        focusedFrameIndex = index
        updateFrameData()
    }
    
    func setOnionSkinOn(_ on: Bool) {
        guard isOnionSkinOn != on else { return }
        isOnionSkinOn = on
        updateFrameData()
    }
    
    func setPlaying(_ playing: Bool) {
        setEditingEnabled(!playing)
    }
    
    func onBeginFrameScroll() {
        setEditingEnabled(false)
    }
    
    func onEndFrameScroll() {
        setEditingEnabled(true)
    }
    
    func setSafeAreaReferenceView(_ view: UIView) {
        canvasVC.setSafeAreaReferenceView(view)
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        canvasVC.handleChangeSafeAreaReferenceViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorFrameEditorVC: EditorFrameEditorCanvasVCDelegate {
    
    func onSelectUndo(_ vc: EditorFrameEditorCanvasVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: EditorFrameEditorCanvasVC) {
        delegate?.onSelectRedo(self)
    }
    
    // TODO: Factor brush and other tool logic into a
    // modal child view controller / manager object?
    func onBeginBrushStroke(quickTap: Bool) {
        guard isEditingEnabled, isActiveDrawingLoaded
        else { return }
        
//        let scale = contentVC.toolOverlayVC.size
//        let smoothingLevel = contentVC.toolOverlayVC.smoothing
        let scale = 1.0
        let smoothingLevel = 0.0
        
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
        guard isEditingEnabled, isActiveDrawingLoaded
        else { return }
        
        let inputStroke = BrushEngineGestureAdapter
            .convert(stroke)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func onEndBrushStroke() {
        guard isEditingEnabled, isActiveDrawingLoaded
        else { return }
        
        brushEngine.endStroke()
    }
    
    func onCancelBrushStroke() {
        guard isEditingEnabled, isActiveDrawingLoaded
        else { return }
        
        brushEngine.cancelStroke()
    }
    
}

extension EditorFrameEditorVC: EditorFrameAssetLoaderDelegate {
    
    func onUpdateProgress(_ loader: EditorFrameAssetLoader) {
        guard let activeDrawingID else { return }
        
        if !isActiveDrawingLoaded,
           let asset = assetLoader.asset(for: activeDrawingID),
           asset.quality == .full
        {
            isActiveDrawingLoaded = true
            brushEngine.setCanvasContents(asset.texture)
        }
        
        if loader.hasLoadedAssetsForAllDrawings() {
            needsDraw = true
        }
    }
    
}

extension EditorFrameEditorVC: EditorFrameActiveDrawingRendererDelegate {
    
    func textureForActiveDrawing(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> MTLTexture? {
        
        guard let activeDrawingID else { return nil }
        
        if isActiveDrawingLoaded {
            return brushEngine.canvasTexture
            
        } else {
            let asset = assetLoader.asset(for: activeDrawingID)
            return asset?.texture
        }
    }
    
    func onionSkinPrevCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int {
        
        prevOnionSkinDrawingIDs.count
    }
    
    func onionSkinNextCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int {
        
        nextOnionSkinDrawingIDs.count
    }
    
    func textureForPrevOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture? {
        
        let drawingID = prevOnionSkinDrawingIDs[index]
        let asset = assetLoader.asset(for: drawingID)
        return asset?.texture
    }
    
    func textureForNextOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture? {
        
        let drawingID = nextOnionSkinDrawingIDs[index]
        let asset = assetLoader.asset(for: drawingID)
        return asset?.texture
    }
    
}

extension EditorFrameEditorVC: EditorFrameSceneRendererDelegate {
    
    func frameScene(
        _ r: EditorFrameSceneRenderer
    ) -> FrameScene? {
        
        frameScene
    }
    
    func textureForDrawing(
        _ r: EditorFrameSceneRenderer,
        drawingID: String
    ) -> MTLTexture? {
        
        if drawingID == activeDrawingID {
            return activeDrawingRenderer.renderTarget
            
        } else {
            let asset = assetLoader.asset(for: drawingID)
            return asset?.texture
        }
    }
    
}

extension EditorFrameEditorVC: BrushEngineDelegate {
    
    func onUpdateCanvas(_ engine: BrushEngine) {
//        needsDraw = true
    }
    
    func onFinalizeStroke(_ engine: BrushEngine) {
//        applyBrushStrokeEdit()
    }
    
}
