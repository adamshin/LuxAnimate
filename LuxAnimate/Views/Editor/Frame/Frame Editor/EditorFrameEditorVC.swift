//
//  EditorFrameEditorVC.swift
//

import UIKit
import Metal

private let onionSkinCount = 1

protocol EditorFrameEditorVCDelegate: AnyObject {
    
    func brushScale(
        _ vc: EditorFrameEditorVC
    ) -> Double
    
    func brushSmoothing(
        _ vc: EditorFrameEditorVC
    ) -> Double
    
    func onSelectUndo(_ vc: EditorFrameEditorVC)
    func onSelectRedo(_ vc: EditorFrameEditorVC)
    
    func onEditDrawing(
        _ vc: EditorFrameEditorVC,
        drawingID: String,
        texture: MTLTexture)
    
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
    private let drawingSize: PixelSize
    
    private var projectManifest: Project.Manifest?
    private var focusedFrameIndex = 0
    private var isOnionSkinOn = false
    
    private var scene: EditorFrameEditorScene?
    
    private var needsDraw = false
    
    // MARK: - Init
    
    init(
        projectID: String,
        projectViewportSize: PixelSize,
        drawingSize: PixelSize
    ) {
        self.projectID = projectID
        self.projectViewportSize = projectViewportSize
        self.drawingSize = drawingSize
        
        drawingEditorVC = EditorFrameDrawingEditorVC(
            drawingSize: drawingSize,
            canvasContentView: canvasVC.canvasContentView)
        
        assetLoader = EditorFrameAssetLoader(
            projectID: projectID)
        
        activeDrawingRenderer = EditorFrameActiveDrawingRenderer(
            drawingSize: drawingSize)
        
        frameSceneRenderer = EditorFrameSceneRenderer(
            viewportSize: projectViewportSize)
        
        super.init(nibName: nil, bundle: nil)
        
        assetLoader.delegate = self
        activeDrawingRenderer.delegate = self
        frameSceneRenderer.delegate = self
        
        displayLink.setCallback { [weak self] in
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
    }
    
    // MARK: - Frame
    
    @objc private func onFrame() {
        drawingEditorVC.onFrame()
        
        if needsDraw {
            needsDraw = false
            draw()
        }
    }
    
    // MARK: - Frame Data
    
    private func updateFrameData() {
        guard let projectManifest else { return }
        
        guard !drawingEditorVC.hasActiveEdit
        else { return }
        
        // Generate scene
        let onionSkinCount = isOnionSkinOn ?
            onionSkinCount : 0
        
        let scene = EditorFrameEditorScene.generate(
            projectManifest: projectManifest,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinPrevCount: onionSkinCount,
            onionSkinNextCount: onionSkinCount)
        
//        let didChangeActiveDrawing =
//            self.scene?.activeDrawingID != scene.activeDrawingID
        
        self.scene = scene
        
//        if didChangeActiveDrawing {
            drawingEditorVC.clearDrawing()
//        }
        
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
    
    func setProjectManifest(_ projectManifest: Project.Manifest) {
        self.projectManifest = projectManifest
        updateFrameData()
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        guard focusedFrameIndex != index else { return }
        focusedFrameIndex = index
        
        drawingEditorVC.endActiveEdit()
        updateFrameData()
    }
    
    func setOnionSkinOn(_ on: Bool) {
        guard isOnionSkinOn != on else { return }
        isOnionSkinOn = on
        
        drawingEditorVC.endActiveEdit()
        updateFrameData()
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
    
    func brushScale(
        _ vc: EditorFrameDrawingEditorVC
    ) -> Double {
        delegate?.brushScale(self) ?? 0
    }
    
    func brushSmoothing(
        _ vc: EditorFrameDrawingEditorVC
    ) -> Double {
        delegate?.brushSmoothing(self) ?? 0
    }
    
    func onUpdateCanvas(
        _ vc: EditorFrameDrawingEditorVC
    ) {
        needsDraw = true
    }
    
    func onEditDrawing(
        _ vc: EditorFrameDrawingEditorVC,
        texture: MTLTexture
    ) {
        guard let activeDrawingID = scene?.activeDrawingID
        else { return }
        
        assetLoader.preCacheFullTexture(
            texture: texture,
            drawingID: activeDrawingID)
        
        delegate?.onEditDrawing(self,
            drawingID: activeDrawingID,
            texture: texture)
    }
    
}

// MARK: - Other Delegates

extension EditorFrameEditorVC: EditorFrameAssetLoaderDelegate {
    
    func onUpdateProgress(_ loader: EditorFrameAssetLoader) {
        guard let activeDrawingID = scene?.activeDrawingID
        else { return }
        
        if let asset = assetLoader.asset(for: activeDrawingID),
           asset.quality == .full
        {
            drawingEditorVC.setDrawingTextureIfNeeded(asset.texture)
        }
        
        if loader.hasAssetsForAllDrawings() {
            needsDraw = true
        }
    }
    
}

extension EditorFrameEditorVC: EditorFrameActiveDrawingRendererDelegate {
    
    func textureForActiveDrawing(
        _ r: EditorFrameActiveDrawingRenderer
    ) -> MTLTexture? {
        
        guard let activeDrawingID = scene?.activeDrawingID
        else { return nil }
        
        if let texture = drawingEditorVC.drawingTexture {
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

extension EditorFrameEditorVC: EditorFrameSceneRendererDelegate {
    
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
