//
//  AnimEditorVC.swift
//

import UIKit

@MainActor
protocol AnimEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: AnimEditorVC)
    func onRequestRedo(_ vc: AnimEditorVC)
    
    func onRequestSceneEdit(
        _ vc: AnimEditorVC,
        sceneEdit: ProjectEditBuilder.SceneEdit,
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
    
    // MARK: - View
    
    private let bodyView = AnimEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC = AnimEditorToolbarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    
    private let timelineVC = AnimEditorTimelineVC()
    
    // MARK: - State
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    
    private var state: AnimEditorState
    private var toolState: AnimEditorToolState?
    private var frameEditor: AnimFrameEditor?
    
    private let editBuilder = AnimEditorEditBuilder()
    
    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = EditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let displayLink = WrappedDisplayLink()
    
    // MARK: - Delegate
    
    weak var delegate: AnimEditorVCDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        layerID: String,
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        focusedFrameIndex: Int
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.layerID = layerID
        
        state = try AnimEditorState(
            projectID: projectID,
            layerID: layerID,
            projectState: projectState,
            sceneManifest: sceneManifest,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinConfig: AppConfig.onionSkinConfig)
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        editBuilder.delegate = self
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
        setupDisplayLink()
        
        setInitialState()
        
        enterToolState(AnimEditorPaintToolState())
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
        
        // TODO: Proper view structure
        addChild(timelineVC, to: bodyView.workspaceContainer)
    }
    
    private func setupDisplayLink() {
        displayLink.setCallback { [weak self] _ in
            self?.onFrame()
        }
    }
    
    // MARK: - State
    
    private func setInitialState() {
        toolbarVC.update(state: state)
        
        timelineVC.update(
            timelineModel: state.timelineModel)
        timelineVC.update(
            focusedFrameIndex: state.focusedFrameIndex)
    }
    
    private func updateState(
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Sendable?
    ) {
        do {
            try state.update(
                projectState: projectState,
                sceneManifest: sceneManifest)
            
            toolbarVC.update(state: state)
            
            timelineVC.update(
                timelineModel: state.timelineModel)
            timelineVC.update(
                focusedFrameIndex: state.focusedFrameIndex)
            
            let shouldReloadFrameEditor: Bool
            if let context = editContext as? AnimEditorVCEditContext,
               context.sender == self,
               context.isFromFrameEditor
            {
                shouldReloadFrameEditor = false
            } else {
                shouldReloadFrameEditor = true
            }
            
            if shouldReloadFrameEditor {
                reloadFrameEditor()
            }
            
        } catch {
            dismiss()
        }
    }
    
    private func updateState(
        focusedFrameIndex: Int,
        fromTimelineVC: Bool
    ) {
        let oldIndex = state.focusedFrameIndex
        
        state.update(
            focusedFrameIndex: focusedFrameIndex)
        
        let newIndex = state.focusedFrameIndex
        
        if oldIndex != newIndex {
            if !fromTimelineVC {
                timelineVC.update(
                    focusedFrameIndex: state.focusedFrameIndex)
            }
            reloadFrameEditor()
        }
    }
    
    private func updateState(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) {
        state.update(
            onionSkinConfig: onionSkinConfig)
        
        reloadFrameEditor()
    }
    
    // MARK: - Frame Editor
    
    private func reloadFrameEditor() {
        guard let toolState else { return }
        
        let frameEditor = AnimFrameEditor()
        frameEditor.delegate = self
        self.frameEditor = frameEditor
        
        frameEditor.begin(
            projectManifest: state.projectState.projectManifest,
            sceneManifest: state.sceneManifest,
            layer: state.layer,
            layerContent: state.layerContent,
            frameIndex: state.focusedFrameIndex,
            onionSkinConfig: state.onionSkinConfig,
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
    
    private func onFrame() {
        autoreleasepool {
            workspaceVC.onFrame()
            
            let sceneGraph = frameEditor?.onFrame()
            if let sceneGraph {
                // Maybe only set this if it changes?
                workspaceVC.setContentSize(sceneGraph.contentSize)
                
                let viewportSize = workspaceVC.viewportSize()
                let workspaceTransform = workspaceVC.workspaceTransform()
                
                draw(
                    viewportSize: viewportSize,
                    workspaceTransform: workspaceTransform,
                    sceneGraph: sceneGraph)
            }
        }
    }
    
    // MARK: - Render
    
    private func draw(
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        guard let drawable = workspaceVC
            .metalView.metalLayer.nextDrawable()
        else { return }
        
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
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Sendable?
    ) {
        updateState(
            projectState: projectState,
            sceneManifest: sceneManifest,
            editContext: editContext)
    }
    
}

// MARK: - Delegates

extension AnimEditorVC: EditorWorkspaceVCDelegate {
    
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
    
    func onChangeContentAreaSize(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineVC,
        _ focusedFrameIndex: Int
    ) {
        updateState(
            focusedFrameIndex: focusedFrameIndex,
            fromTimelineVC: true)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onRequestCreateDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        try? editBuilder.createDrawing(
            state: state,
            frameIndex: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        try? editBuilder.deleteDrawing(
            state: state,
            frameIndex: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        try? editBuilder.insertSpacing(
            state: state,
            frameIndex: frameIndex)
    }
    
    func onRequestRemoveSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        try? editBuilder.removeSpacing(
            state: state,
            frameIndex: frameIndex)
    }
    
}

extension AnimEditorVC: AnimFrameEditor.Delegate {
    
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
    
    func assetLoaderHasLoadedAssets(
        _ e: AnimFrameEditor,
        assetIDs: Set<String>
    ) -> Bool {
        assetIDs.isSubset(of: assetLoader.loadedAssets.keys)
    }
    
    func assetLoaderAsset(
        _ e: AnimFrameEditor,
        assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset? {
        assetLoader.loadedAssets[assetID]
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
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        let editContext = AnimEditorVCEditContext(
            sender: self,
            isFromFrameEditor: true)
        
        try? editBuilder.editDrawing(
            state: state,
            drawingID: drawingID,
            imageSet: imageSet,
            editContext: editContext)
    }
    
}

extension AnimEditorVC: AnimEditorEditBuilder.Delegate {
    
    func onRequestSceneEdit(
        _ b: AnimEditorEditBuilder,
        sceneEdit: ProjectEditBuilder.SceneEdit,
        editContext: Sendable?
    ) {
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
    
}
