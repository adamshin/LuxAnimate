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
// copied. Loaded asset textures are fine to include
// directly since they're never modified once created.

// TODO:
// Factor out frame editor container?
// Factor out tool state machine?

@MainActor
protocol AnimEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: AnimEditorVC)
    func onRequestRedo(_ vc: AnimEditorVC)
    
    func onRequestSceneEdit(
        _ vc: AnimEditorVC,
        sceneEdit: ProjectEditHelper.SceneEdit,
        editContext: Sendable?)
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset?
    
}

struct AnimEditorVCEditContext {
    var sender: AnimEditorVC
    var isFromFrameEditor: Bool
}

class AnimEditorVC: UIViewController {
    
    private let bodyView = AnimEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC = AnimEditorToolbarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    
    private let timelineVC: AnimEditorTimelineVC
    
    private let assetLoader: AnimEditorAssetLoader
    private let frameEditProcessor: AnimFrameEditProcessor
    
    private let workspaceRenderer = EditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    
    private var projectEditManagerState: ProjectEditManager.State
    private var sceneManifest: Scene.Manifest
    private var layer: Scene.Layer
    private var animationLayerContent: Scene.AnimationLayerContent
    
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
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.projectEditManagerState = projectEditManagerState
        self.sceneManifest = sceneManifest
        self.activeFrameIndex = activeFrameIndex
        
        let (layer, animationLayerContent) =
            try AnimEditorLayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: activeLayerID)
        
        self.layer = layer
        self.animationLayerContent = animationLayerContent
        
        timelineVC = AnimEditorTimelineVC(
            projectID: projectID,
            sceneManifest: sceneManifest,
            animationLayerContent: animationLayerContent,
            focusedFrameIndex: activeFrameIndex)
        
        onionSkinConfig = AppConfig.onionSkinConfig
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        frameEditProcessor = AnimFrameEditProcessor(
            layerID: activeLayerID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        frameEditProcessor.delegate = self
        assetLoader.delegate = self
        
        clampActiveFrameIndex()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
        
        setupToolState()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        timelineVC.delegate = self
        
        addChild(workspaceVC, to: bodyView.workspaceContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(toolControlsVC, to: bodyView.toolControlsContainer)
        
        // TODO: Proper view containment
        addChild(timelineVC, to: bodyView.workspaceContainer)
    }
    
    private func setupToolState() {
        enterToolStateInternal(AnimEditorPaintToolState())
    }
    
    // MARK: - UI
    
    private func updateUI() {
        toolbarVC.update(
            availableUndoCount: projectEditManagerState.availableUndoCount,
            availableRedoCount: projectEditManagerState.availableRedoCount)
        
//        timelineVC.update(
//            projectID: projectID,
//            sceneManifest: sceneManifest,
//            animationLayerContent: ??)
    }
    
    // MARK: - Logic
    
    private func updateState(
        projectEditManagerState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Sendable?
    ) {
        guard let (layer, animationLayerContent) =
            try? AnimEditorLayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: activeLayerID)
        else {
            dismiss()
            return
        }
        
        self.projectEditManagerState = projectEditManagerState
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.animationLayerContent = animationLayerContent
        
        timelineVC.update(
            sceneManifest: sceneManifest,
            animationLayerContent: animationLayerContent)
        
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
        updateUI()
        
        // TODO: Factor this out into a frame editor container object?
        if shouldReloadFrameEditor {
            reloadFrameEditor()
        }
    }
    
    private func updateState(
        activeFrameIndex: Int
    ) {
        self.activeFrameIndex = activeFrameIndex
        clampActiveFrameIndex()
        
        updateUI()
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
        enterToolStateInternal(newToolState)
    }
    
    private func enterToolStateInternal(
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
        drawable: CAMetalDrawable
    ) {
        let sceneGraph = frameEditor?.onFrame()
        
        if let sceneGraph {
            // Maybe only set this if it changes?
            workspaceVC.setContentSize(sceneGraph.contentSize)
            
            let viewportSize = workspaceVC.viewportSize()
            let workspaceTransform = workspaceVC.workspaceTransform()
            
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
        editContext: Sendable?
    ) {
        updateState(
            projectEditManagerState: projectEditManagerState,
            sceneManifest: sceneManifest,
            editContext: editContext)
    }
    
}

// MARK: - Delegates

extension AnimEditorVC: EditorWorkspaceVCDelegate {
    
    func onFrame(
        _ vc: EditorWorkspaceVC,
        drawable: CAMetalDrawable
    ) {
        onFrame(drawable: drawable)
    }
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

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

extension AnimEditorVC: AnimEditorTimelineVC.Delegate {
    
    func onChangeFocusedFrame(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        updateState(activeFrameIndex: frameIndex)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onRequestCreateDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) { }
    
    func onRequestDeleteDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) { }
    
    func onRequestInsertSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) { }
    
    func onRequestRemoveSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) { }
    
    func onChangeContentAreaSize(
        _ vc: AnimEditorTimelineVC
    ) { }
    
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
    
    func setEditInteractionEnabled(
        _ e: AnimFrameEditor,
        enabled: Bool
    ) {
        toolState?.setEditInteractionEnabled(enabled)
    }
    
    func onEdit(
        _ e: AnimFrameEditor,
        drawingID: String,
        drawingTexture: MTLTexture?
    ) {
        // TODO: Is this logic right?
        // Subsequent edits need to stack on top of each other
        // Do we need an updated scene manifest each time?
        // Maybe this is fine since we're just editing a single drawing
        frameEditProcessor.applyEdit(
            sceneManifest: sceneManifest,
            drawingID: drawingID,
            drawingTexture: drawingTexture)
    }
    
}

extension AnimEditorVC: AnimFrameEditProcessor.Delegate {
    
    func onRequestSceneEdit(
        _ p: AnimFrameEditProcessor,
        sceneEdit: ProjectEditHelper.SceneEdit
    ) {
        // Should isFromFrameEditor always be true?
        // We may want the ability to dispatch edits from
        // here that don't come from the frame editor.
        let editContext = AnimEditorVCEditContext(
            sender: self,
            isFromFrameEditor: true)
        
        delegate?.onRequestSceneEdit(
            self,
            sceneEdit: sceneEdit,
            editContext: editContext)
    }
    
}

extension AnimEditorVC: AnimEditorAssetLoader.Delegate {
    
    func pendingAssetData(
        _ l: AnimEditorAssetLoader,
        assetID: String
    ) -> Data? {
        
        if let pendingAsset = delegate?
            .pendingEditAsset(assetID: assetID)
        {
            return pendingAsset.data
        }
        return nil
    }
    
    func onUpdate(_ l: AnimEditorAssetLoader) {
        frameEditor?.onAssetLoaderUpdate()
    }
    
    func onFinish(_ l: AnimEditorAssetLoader) {
        frameEditor?.onAssetLoaderFinish()
    }
    
}
