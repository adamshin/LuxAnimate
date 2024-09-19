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
    
    private let bodyView = AnimEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC = AnimEditorToolbarVC()
    private let toolControlsVC = AnimEditorToolControlsVC()
    
    private let timelineVC: AnimEditorTimelineVC
    
    private let assetLoader: AnimEditorAssetLoader
    
    private let workspaceRenderer = EditorWorkspaceRenderer(
        pixelFormat: AppConfig.metalLayerPixelFormat)
    
    private let displayLink = WrappedDisplayLink()
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    
    private var projectState: ProjectEditManager.State
    private var sceneManifest: Scene.Manifest
    private var layer: Scene.Layer
    private var layerContent: Scene.AnimationLayerContent
    
    private var focusedFrameIndex: Int
    
    private var onionSkinConfig: AnimEditorOnionSkinConfig
    
    private var toolState: AnimEditorToolState?
    private var frameEditor: AnimFrameEditor?
    
    weak var delegate: AnimEditorVCDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        focusedFrameIndex unclampedFocusedFrameIndex: Int
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.projectState = projectState
        self.sceneManifest = sceneManifest
        
        self.focusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: unclampedFocusedFrameIndex,
            sceneManifest: sceneManifest)
        
        let (layer, layerContent) =
            try AnimEditorLayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: activeLayerID)
        
        self.layer = layer
        self.layerContent = layerContent
        
        let timelineModel = AnimEditorTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            layerContent: layerContent)
        
        timelineVC = AnimEditorTimelineVC(
            timelineModel: timelineModel,
            focusedFrameIndex: focusedFrameIndex)
        
        onionSkinConfig = AppConfig.onionSkinConfig
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        toolbarVC.update(
            availableUndoCount: projectState.availableUndoCount,
            availableRedoCount: projectState.availableRedoCount)
        
        assetLoader.delegate = self
        
        enterToolState(AnimEditorPaintToolState())
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
    
    // MARK: - Logic
    
    private func updateState(
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        editContext: Sendable?
    ) {
        guard let (layer, layerContent) =
            try? AnimEditorLayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: activeLayerID)
        else {
            dismiss()
            return
        }
        
        self.projectState = projectState
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        
        focusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: focusedFrameIndex,
            sceneManifest: sceneManifest)
        
        toolbarVC.update(
            availableUndoCount: projectState.availableUndoCount,
            availableRedoCount: projectState.availableRedoCount)
        
        let timelineModel = AnimEditorTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            layerContent: layerContent)
        
        timelineVC.update(timelineModel: timelineModel)
        timelineVC.update(focusedFrameIndex: focusedFrameIndex)
        
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
    }
    
    private func updateState(
        focusedFrameIndex unclampedFocusedFrameIndex: Int,
        fromTimelineVC: Bool
    ) {
        let newFocusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: unclampedFocusedFrameIndex,
            sceneManifest: sceneManifest)
        
        guard newFocusedFrameIndex != focusedFrameIndex
        else { return }
        
        focusedFrameIndex = newFocusedFrameIndex
        
        if !fromTimelineVC {
            timelineVC.update(
                focusedFrameIndex: focusedFrameIndex)
        }
        
        reloadFrameEditor()
    }
    
    private func updateState(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) {
        self.onionSkinConfig = onionSkinConfig
        reloadFrameEditor()
    }
    
    private static func clampedFocusedFrameIndex(
        focusedFrameIndex: Int,
        sceneManifest: Scene.Manifest
    ) -> Int {
        clamp(
            focusedFrameIndex,
            min: 0,
            max: sceneManifest.frameCount - 1)
    }
    
    // MARK: - Frame Editor
    
    private func reloadFrameEditor() {
        guard let toolState else { return }
        
        let frameEditor = AnimFrameEditor()
        frameEditor.delegate = self
        self.frameEditor = frameEditor
        
        frameEditor.begin(
            projectManifest: projectState.projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: focusedFrameIndex,
            onionSkinConfig: onionSkinConfig,
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
        do {
            let layerContentEdit = try AnimationLayerEditBuilder
                .createDrawing(
                    layerContent: layerContent,
                    frameIndex: frameIndex)
            
            let sceneEdit = try AnimationLayerEditBuilder
                .applyAnimationLayerContentEdit(
                    sceneManifest: sceneManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)
            
            delegate?.onRequestSceneEdit(
                self,
                sceneEdit: sceneEdit,
                editContext: nil)
            
        } catch { }
    }
    
    func onRequestDeleteDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        do {
            let layerContentEdit = AnimationLayerEditBuilder
                .deleteDrawing(
                    layerContent: layerContent,
                    frameIndex: frameIndex)
            
            let sceneEdit = try AnimationLayerEditBuilder
                .applyAnimationLayerContentEdit(
                    sceneManifest: sceneManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)
            
            delegate?.onRequestSceneEdit(
                self,
                sceneEdit: sceneEdit,
                editContext: nil)
            
        } catch { }
    }
    
    func onRequestInsertSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        do {
            let layerContentEdit = AnimationLayerEditBuilder
                .insertSpacing(
                    layerContent: layerContent,
                    frameIndex: frameIndex)
            
            let sceneEdit = try AnimationLayerEditBuilder
                .applyAnimationLayerContentEdit(
                    sceneManifest: sceneManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)
            
            delegate?.onRequestSceneEdit(
                self,
                sceneEdit: sceneEdit,
                editContext: nil)
            
        } catch { }
    }
    
    func onRequestRemoveSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
        do {
            let layerContentEdit = try AnimationLayerEditBuilder
                .removeSpacing(
                    layerContent: layerContent,
                    frameIndex: frameIndex)
            
            let sceneEdit = try AnimationLayerEditBuilder
                .applyAnimationLayerContentEdit(
                    sceneManifest: sceneManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)
            
            delegate?.onRequestSceneEdit(
                self,
                sceneEdit: sceneEdit,
                editContext: nil)
            
        } catch { }
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
        do {
            let imageSet = AnimationLayerEditBuilder
                .DrawingImageSet(
                    full: imageSet.full,
                    thumbnail: imageSet.thumbnail)
            
            let sceneEdit = try AnimationLayerEditBuilder
                .editDrawing(
                    sceneManifest: sceneManifest,
                    layerID: layer.id,
                    drawingID: drawingID,
                    imageSet: imageSet)
            
            let editContext = AnimEditorVCEditContext(
                sender: self,
                isFromFrameEditor: true)
            
            delegate?.onRequestSceneEdit(
                self,
                sceneEdit: sceneEdit,
                editContext: editContext)
            
        } catch { }
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
