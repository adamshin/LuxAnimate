//
//  AnimEditorVC.swift
//

import UIKit

// Currently, we're asking the frame editor for a fresh
// scene graph every frame. We should only do this when the
// scene graph changes.

// Also: maybe we should store the scene graph so we can
// render the workspace even while the frame editor is
// loading new frame data, etc. This would keep the
// workspace responsive to pan/zoom input.

// This means the workspace scene graph needs to contain
// all the texture data needed to render itself. Textures
// that may be mutated, like tool render buffers, should be
// copied. Loaded asset textures are fine to include since
// they won't be modified once created.

protocol AnimEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: AnimEditorVC)
    func onRequestRedo(_ vc: AnimEditorVC)
    
    func onRequestSceneEdit(
        _ vc: AnimEditorVC,
        sceneEdit: ProjectEditHelper.SceneEdit,
        editContext: Any?)
    
}

struct AnimEditorVCEditContext {
    var sender: AnimEditorVC
    var isFromFrameEditor: Bool
}

class AnimEditorVC: UIViewController {
    
    private let bodyView = AnimEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC = AnimEditorToolbarVC()
    private let bottomBarVC = AnimEditorBottomBarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    
    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = EditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    
    private var projectEditManagerState: ProjectEditManager.State
    private var sceneManifest: Scene.Manifest
    private var activeFrameIndex: Int
    
    private var onionSkinConfig: AnimEditorOnionSkinConfig
    
    private var toolState: AnimEditorToolState?
    private var frameEditor: AnimFrameEditor?
    
    weak var delegate: AnimEditorVCDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        projectEditManagerState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        activeFrameIndex: Int
    ) {
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.projectEditManagerState = projectEditManagerState
        self.sceneManifest = sceneManifest
        self.activeFrameIndex = activeFrameIndex
        
        onionSkinConfig = AppConfig.onionSkinConfig
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        assetLoader.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        clampActiveFrameIndex()
        updateToolbar()
        updateBottomBar()
        enterToolState(AnimEditorPaintToolState())
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        bottomBarVC.delegate = self
        
        addChild(workspaceVC, to: bodyView.workspaceContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(bottomBarVC, to: bodyView.bottomBarContainer)
        addChild(toolControlsVC, to: bodyView.toolControlsContainer)
    }
    
    // MARK: - UI
    
    private func updateToolbar() {
        toolbarVC.update(
            availableUndoCount: projectEditManagerState.availableUndoCount,
            availableRedoCount: projectEditManagerState.availableRedoCount)
    }
    
    private func updateBottomBar() {
        bottomBarVC.update(
            activeFrameIndex: activeFrameIndex)
    }
    
    // MARK: - Logic
    
    private func updateState(
        projectEditManagerState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Any?
    ) {
        guard sceneManifest.layers
            .contains(where: { $0.id == activeLayerID })
        else {
            dismiss()
            return
        }
        
        self.projectEditManagerState = projectEditManagerState
        self.sceneManifest = sceneManifest
        
        let shouldReloadFrameEditor: Bool
        if let context = editContext as? AnimEditorVCEditContext,
            context.sender == self,
            context.isFromFrameEditor
        {
            shouldReloadFrameEditor = false
        } else {
            shouldReloadFrameEditor = true
        }
        
        clampActiveFrameIndex()
        
        updateToolbar()
        updateBottomBar()
        
        if shouldReloadFrameEditor {
            reloadFrameEditor()
        }
    }
    
    private func updateState(
        activeFrameIndex: Int
    ) {
        self.activeFrameIndex = activeFrameIndex
        
        clampActiveFrameIndex()
        updateBottomBar()
        reloadFrameEditor()
    }
    
    private func updateState(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) {
        self.onionSkinConfig = onionSkinConfig
        reloadFrameEditor()
    }
    
    private func clampActiveFrameIndex() {
        activeFrameIndex = clamp(
            activeFrameIndex,
            min: 0,
            max: sceneManifest.frameCount - 1)
    }
    
    private func reloadFrameEditor() {
        guard let toolState else { return }
        
        let projectManifest = projectEditManagerState
            .projectManifest
        
        let frameEditor = AnimFrameEditor()
        frameEditor.delegate = self
        self.frameEditor = frameEditor
        
        frameEditor.begin(
            projectID: projectID,
            sceneID: sceneID,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinConfig: onionSkinConfig,
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            editorToolState: toolState)
    }
    
    // MARK: - Tool State
    
    private func enterToolState(
        _ newToolState: AnimEditorToolState
    ) {
        toolState?.endState(
            workspaceVC: workspaceVC,
            toolControlsVC: toolControlsVC)
        
        toolState = newToolState
        
        newToolState.beginState(
            workspaceVC: workspaceVC,
            toolControlsVC: toolControlsVC)
        
        reloadFrameEditor()
    }
    
    // MARK: - Frame
    
    private func onFrame(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform
    ) {
        let sceneGraph = frameEditor?.onFrame()
        
        if let sceneGraph {
            // Maybe only set this if it changes?
            workspaceVC.setContentSize(sceneGraph.contentSize)
            
            draw(
                drawable: drawable,
                viewportSize: viewportSize,
                workspaceTransform: workspaceTransform,
                sceneGraph: sceneGraph)
        }
    }
    
    // MARK: - Render
    
    private func draw(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        workspaceRenderer.draw(
            target: drawable.texture,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform,
            sceneGraph: sceneGraph)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Navigation
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    // MARK: - Interface
    
    func update(
        projectEditManagerState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Any?
    ) {
        updateState(
            projectEditManagerState: projectEditManagerState,
            sceneManifest: sceneManifest,
            editContext: editContext)
    }
    
}

// MARK: - Delegates

extension AnimEditorVC: AnimEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: AnimEditorToolbarVC) {
        dismiss()
    }
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorPaintToolState())
    }
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC) {
        enterToolState(AnimEditorEraseToolState())
    }
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC: AnimEditorBottomBarVCDelegate {
    
    func onSelectPrevFrame(_ vc: AnimEditorBottomBarVC) {
        updateState(activeFrameIndex: activeFrameIndex - 1)
    }
    func onSelectNextFrame(_ vc: AnimEditorBottomBarVC) {
        updateState(activeFrameIndex: activeFrameIndex + 1)
    }
    
}

extension AnimEditorVC: EditorWorkspaceVCDelegate {
    
    func onFrame(
        _ vc: EditorWorkspaceVC,
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform
    ) {
        onFrame(
            drawable: drawable,
            viewportSize: viewportSize,
            workspaceTransform: workspaceTransform)
    }
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC: AnimEditorAssetLoaderDelegate {
    
    func onUpdate(_ l: AnimEditorAssetLoader) {
        frameEditor?.onAssetLoaderUpdate()
    }
    
    func onFinish(_ l: AnimEditorAssetLoader) {
        frameEditor?.onAssetLoaderFinish()
    }
    
}

extension AnimEditorVC: AnimFrameEditorDelegate {
    
    func workspaceViewSize(
        _ e: AnimFrameEditor
    ) -> Size {
        Size(workspaceVC.view.bounds.size)
    }
    
    func workspaceTransform(
        _ e: AnimFrameEditor
    ) -> EditorWorkspaceTransform {
        workspaceVC.workspaceTransform()
    }
    
    func setAssetLoaderAssetIDs(
        _ e: AnimFrameEditor,
        assetIDs: Set<String>
    ) {
        assetLoader.update(assetIDs: assetIDs)
    }
    
    func assetLoaderAssetTexture(
        _ e: AnimFrameEditor,
        assetID: String
    ) -> MTLTexture? {
        let asset = assetLoader.loadedAsset(assetID: assetID)
        return asset?.texture
    }
    
    func storeAssetLoaderTexture(
        _ e: AnimFrameEditor,
        assetID: String,
        texture: MTLTexture
    ) {
        assetLoader.storeAssetTexture(
            assetID: assetID,
            texture: texture)
    }
    
    func setEditInteractionEnabled(
        _ e: AnimFrameEditor,
        enabled: Bool
    ) {
        toolState?.setEditInteractionEnabled(enabled)
    }
    
    // For testing
    func editDrawing(
        _ e: AnimFrameEditor,
        drawingID: String,
        fullAssetID: String
    ) {
        sceneManifest.layers = sceneManifest.layers.map { layer in
            if case .animation(let content) = layer.content {
                let newDrawings = content.drawings.map { drawing in
                    if drawing.id == drawingID {
                        var newDrawing = drawing
                        newDrawing.assetIDs = Scene.DrawingAssetIDGroup(
                            full: fullAssetID, 
                            medium: "",
                            small: "")
                        return newDrawing
                    } else {
                        return drawing
                    }
                }
                var newContent = content
                newContent.drawings = newDrawings
                
                var newLayer = layer
                newLayer.content = .animation(newContent)
                return newLayer
                
            } else {
                return layer
            }
        }
    }
    
}
