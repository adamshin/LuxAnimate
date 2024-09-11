//
//  EditorFrameEditorVC.swift
//

import UIKit
import Metal

private let onionSkinCount = 2

protocol EditorFrameEditorVCDelegate: AnyObject {
    
    func onSetBrushScale(
        _ vc: EditorFrameEditorVC,
        _ brushScale: Double)
    
    func onSetBrushSmoothing(
        _ vc: EditorFrameEditorVC,
        _ brushSmoothing: Double)
    
    func onSelectUndo(_ vc: EditorFrameEditorVC)
    func onSelectRedo(_ vc: EditorFrameEditorVC)
    
    func onEditDrawing(
        _ vc: EditorFrameEditorVC,
        drawingID: String,
        drawingTexture: MTLTexture)
    
}

class EditorFrameEditorVC: UIViewController {
    
    weak var delegate: EditorFrameEditorVCDelegate?
    
    private let canvasVC = EditorFrameEditorCanvasVC()
    private let drawingEditorVC: EditorFrameDrawingEditorVC
    
    private let assetLoader: EditorFrameAssetLoader
    private let activeDrawingRenderer: EditorFrameActiveDrawingRenderer
    private let frameSceneRenderer: EditorFrameSceneRenderer
    private let displayLink = WrappedDisplayLink()
    
    private let projectID: String
    private let projectViewportSize: PixelSize
    private let layerContentSize: PixelSize
    
    private var projectManifest: Project.Manifest?
    private var focusedFrameIndex = 0
    private var isOnionSkinOn = false
    
    private var scene: EditorFrameEditorScene?
    
    private var needsDraw = false
    
    // MARK: - Init
    
    init(
        projectID: String,
        projectViewportSize: PixelSize,
        layerContentSize: PixelSize
    ) throws {
        self.projectID = projectID
        self.projectViewportSize = projectViewportSize
        self.layerContentSize = layerContentSize
        
        drawingEditorVC = try EditorFrameDrawingEditorVC(
            drawingSize: layerContentSize,
            canvasContentView: canvasVC.canvasContentView)
        
        assetLoader = EditorFrameAssetLoader(
            projectID: projectID)
        
        activeDrawingRenderer = EditorFrameActiveDrawingRenderer(
            drawingSize: layerContentSize)
        
        frameSceneRenderer = EditorFrameSceneRenderer(
            viewportSize: projectViewportSize)
        
        super.init(nibName: nil, bundle: nil)
        
        assetLoader.delegate = self
        activeDrawingRenderer.delegate = self
        frameSceneRenderer.delegate = self
        
        displayLink.setCallback { [weak self] _ in
            self?.onFrame()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasVC.delegate = self
        drawingEditorVC.delegate = self
        
        addChild(canvasVC, to: view)
        addChild(drawingEditorVC, to: view)
        
        canvasVC.setCanvasSize(projectViewportSize)
        
        drawingEditorVC.selectBrushTool()
    }
    
    // MARK: - Frame
    
    @objc private func onFrame() {
        drawingEditorVC.onFrame()
        
        if needsDraw {
            needsDraw = false
            draw()
        }
    }
    
    // MARK: - Scene
    
    private func updateScene() {
        guard let projectManifest else { return }
        
        // Reset drawing editor
        drawingEditorVC.clearDrawingTexture()
        
        // Generate scene
        let onionSkinCount = isOnionSkinOn ?
            onionSkinCount : 0
        
        let scene = EditorFrameEditorScene.generate(
            projectManifest: projectManifest,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinPrevCount: onionSkinCount,
            onionSkinNextCount: onionSkinCount)
        
        self.scene = scene
        
        // Load assets
        assetLoader.loadAssets(
            drawings: scene.allDrawings,
            activeDrawingID: scene.activeDrawingID)
        
        if assetLoader.hasAssetsForAllDrawings() {
            needsDraw = true
        }
    }
    
    // MARK: - Rendering
    
    private func draw() {
        guard assetLoader.hasAssetsForAllDrawings()
        else { return }
        
        activeDrawingRenderer.draw()
        frameSceneRenderer.draw()
        
        canvasVC.setCanvasTexture(
            frameSceneRenderer.renderTarget)
    }
    
    // MARK: - Editing
    
    private func setEditingEnabled(_ enabled: Bool) {
        canvasVC.setEditingEnabled(enabled)
        drawingEditorVC.setEditingEnabled(enabled)
    }
    
    // MARK: - Interface
    
    func setProjectManifest(
        _ projectManifest: Project.Manifest,
        editContext: Any?
    ) {
        self.projectManifest = projectManifest
        
//        if let scene,
//            let c = editContext as? EditContext,
//            c.origin == self,
//            c.focusedFrameIndex == focusedFrameIndex,
//            c.activeDrawingID == scene.activeDrawingID
//        {
//            return
//        }
        
        drawingEditorVC.endActiveEdit()
        updateScene()
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        guard focusedFrameIndex != index else { return }
        
        drawingEditorVC.endActiveEdit()
        
        focusedFrameIndex = index
        updateScene()
    }
    
    func setOnionSkinOn(_ on: Bool) {
        guard isOnionSkinOn != on else { return }
        
        drawingEditorVC.endActiveEdit()
        
        isOnionSkinOn = on
        updateScene()
    }
    
    func setPlaying(_ playing: Bool) {
        setEditingEnabled(!playing)
    }
    
    func onBeginFrameScroll() { }
    
    func onEndFrameScroll() { }
    
    func setSafeAreaReferenceView(_ view: UIView) {
        canvasVC.setSafeAreaReferenceView(view)
    }
    
    func handleChangeSafeAreaReferenceViewFrame() {
        canvasVC.handleChangeSafeAreaReferenceViewFrame()
    }
    
    func selectBrushTool() {
        drawingEditorVC.selectBrushTool()
    }
    func selectEraseTool() {
        drawingEditorVC.selectEraseTool()
    }
    
    func setBrushScale(_ brushScale: Double) {
        drawingEditorVC.setBrushScale(brushScale)
    }
    func setBrushSmoothing(_ brushSmoothing: Double) {
        drawingEditorVC.setBrushSmoothing(brushSmoothing)
    }
    
}

// MARK: - View Controller Delegates

extension EditorFrameEditorVC: EditorFrameEditorCanvasVCDelegate {
    
    func onSelectUndo(_ vc: EditorFrameEditorCanvasVC) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ vc: EditorFrameEditorCanvasVC) {
        delegate?.onSelectRedo(self)
    }
    
}

extension EditorFrameEditorVC: EditorFrameDrawingEditorVCDelegate {
    
    func onSetBrushScale(
        _ vc: EditorFrameDrawingEditorVC,
        _ brushScale: Double
    ) {
        delegate?.onSetBrushScale(self, brushScale)
    }
    
    func onSetBrushSmoothing(
        _ vc: EditorFrameDrawingEditorVC,
        _ brushSmoothing: Double
    ) {
        delegate?.onSetBrushSmoothing(self, brushSmoothing)
    }
    
    func onUpdateActiveDrawingTexture(
        _ vc: EditorFrameDrawingEditorVC
    ) {
        needsDraw = true
    }
    
    func onEditDrawing(
        _ vc: EditorFrameDrawingEditorVC,
        drawingTexture: MTLTexture
    ) {
        guard let activeDrawingID = scene?.activeDrawingID
        else { return }
        
        delegate?.onEditDrawing(self,
            drawingID: activeDrawingID,
            drawingTexture: drawingTexture)
    }
    
}

// MARK: - Other Delegates

extension EditorFrameEditorVC: @preconcurrency EditorFrameAssetLoaderDelegate {
    
    func onUpdateProgress(_ loader: EditorFrameAssetLoader) {
        guard let activeDrawingID = scene?.activeDrawingID
        else { return }
        
        if let asset = assetLoader.asset(for: activeDrawingID),
           asset.quality == .full
        {
            drawingEditorVC.setDrawingTexture(asset.texture)
        }
        
        if loader.hasAssetsForAllDrawings() {
            needsDraw = true
        }
    }
    
}

extension EditorFrameEditorVC: @preconcurrency EditorFrameActiveDrawingRendererDelegate {
    
    func textureForActiveDrawing(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> MTLTexture? {
        
        guard let activeDrawingID = scene?.activeDrawingID
        else { return nil }
        
        if let texture = drawingEditorVC.activeDrawingTexture {
            return texture
        } else {
            let asset = assetLoader.asset(for: activeDrawingID)
            return asset?.texture
        }
    }
    
    func onionSkinPrevCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int {
        guard let scene else { return 0 }
        return scene.prevOnionSkinDrawingIDs.count
    }
    
    func onionSkinNextCount(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> Int {
        guard let scene else { return 0 }
        return scene.nextOnionSkinDrawingIDs.count
    }
    
    func textureForPrevOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture? {
        guard let scene else { return nil }
        let drawingID = scene.prevOnionSkinDrawingIDs[index]
        let asset = assetLoader.asset(for: drawingID)
        return asset?.texture
    }
    
    func textureForNextOnionSkinDrawing(
        _ r: EditorFrameActiveDrawingRenderer,
        index: Int
    ) -> MTLTexture? {
        guard let scene else { return nil }
        let drawingID = scene.nextOnionSkinDrawingIDs[index]
        let asset = assetLoader.asset(for: drawingID)
        return asset?.texture
    }
    
}

extension EditorFrameEditorVC: @preconcurrency EditorFrameSceneRendererDelegate {
    
    func frameScene(
        _ r: EditorFrameSceneRenderer
    ) -> FrameScene? {
        
        scene?.frameScene
    }
    
    func textureForDrawing(
        _ r: EditorFrameSceneRenderer,
        drawingID: String
    ) -> MTLTexture? {
        
        if drawingID == scene?.activeDrawingID {
            return activeDrawingRenderer.renderTarget
            
        } else {
            let asset = assetLoader.asset(for: drawingID)
            return asset?.texture
        }
    }
    
}
