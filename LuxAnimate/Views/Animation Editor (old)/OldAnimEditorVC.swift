//
//  OldAnimEditorVC.swift
//

import UIKit
import Geometry

@MainActor
protocol OldAnimEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: OldAnimEditorVC)
    func onRequestRedo(_ vc: OldAnimEditorVC)
    
    func onRequestSceneEdit(
        _ vc: OldAnimEditorVC,
        sceneEdit: ProjectEditBuilder.SceneEdit)
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset?
    
}

class OldAnimEditorVC: UIViewController {
    
    // MARK: - View
    
//    private let bodyView = AnimEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
//    private let toolbarVC = AnimEditorToolbarVC()
//    private let toolControlsVC = AnimEditorToolControlsVC()
    
//    private let timelineVC: AnimEditorTimelineVC
    
    // MARK: - State
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    
//    private var state: AnimEditorState
    
    private var toolState: AnimEditorToolState?
    private var frameEditor: AnimFrameEditor?
    
    private let assetLoader: AnimEditorAssetLoader
    private let editBuilder = AnimEditorEditBuilder()
    private let workspaceRenderer = EditorWorkspaceRenderer()
    
    private let displayLink = WrappedDisplayLink()
    
    // MARK: - Delegate
    
//    weak var delegate: AnimEditorVCDelegate?
    
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
        
//        timelineVC = AnimEditorTimelineVC(
//            projectID: projectID)
        
//        state = try AnimEditorState(
//            projectID: projectID,
//            layerID: layerID,
//            projectState: projectState,
//            sceneManifest: sceneManifest,
//            focusedFrameIndex: focusedFrameIndex,
//            onionSkinOn: false,
//            onionSkinConfig: AppConfig.onionSkinConfig,
//            selectedTool: .paint)
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
//        workspaceVC.delegate = self
//        toolbarVC.delegate = self
//        timelineVC.delegate = self
        
//        assetLoader.delegate = self
//        editBuilder.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
//    override func loadView() {
//        self.view = bodyView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDisplayLink()
        
        setInitialState()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
//        addChild(workspaceVC, to: bodyView.workspaceContainer)
//        addChild(toolbarVC, to: bodyView.toolbarContainer)
//        addChild(toolControlsVC, to: bodyView.toolControlsContainer)
        
        // TODO: Proper view structure
//        addChild(timelineVC, to: bodyView.workspaceContainer)
    }
    
    private func setupDisplayLink() {
//        displayLink.setCallback { [weak self] _ in
//            self?.onFrame()
//        }
    }
    
    // MARK: - State
    
    private func setInitialState() {
//        toolbarVC.update(
//            projectState: state.projectState)
//        toolbarVC.update(
//            selectedTool: state.selectedTool)
//        toolbarVC.update(
//            onionSkinOn: state.onionSkinOn)
        
//        timelineVC.update(
//            timelineModel: state.timelineModel)
//        timelineVC.update(
//            focusedFrameIndex: state.focusedFrameIndex)
        
//        updateToolState(
//            selectedTool: state.selectedTool)
        
        updateFrameEditor()
    }
    
//    private func applyStateUpdate(
//        update: AnimEditorState.Update,
//        fromFrameEditor: Bool = false,
//        fromTimeline: Bool = false
//    ) {
//        let state = update.state
//        let changes = update.changes
//        
//        self.state = state
//        
//        if changes.projectState {
//            toolbarVC.update(
//                projectState: state.projectState)
//        }
//        if changes.selectedTool {
//            toolbarVC.update(
//                selectedTool: state.selectedTool)
//        }
//        if changes.onionSkin {
//            toolbarVC.update(
//                onionSkinOn: state.onionSkinOn)
//        }
//        
//        if !fromTimeline, changes.timelineModel {
//            timelineVC.update(
//                timelineModel: state.timelineModel)
//        }
//        if !fromTimeline, changes.focusedFrameIndex {
//            timelineVC.update(
//                focusedFrameIndex: state.focusedFrameIndex)
//        }
//        
//        if changes.selectedTool {
//            updateToolState(
//                selectedTool: state.selectedTool)
//        }
//        
//        if !fromFrameEditor,
//            changes.projectState ||
//            changes.focusedFrameIndex ||
//            changes.onionSkin ||
//            changes.selectedTool
//        {
//            updateFrameEditor()
//        }
//    }
    
    // MARK: - Tool State
    
//    private func updateToolState(
//        selectedTool: AnimEditorState.Tool
//    ) {
//        switch selectedTool {
//        case .paint: enterToolState(AnimEditorPaintToolState())
//        case .erase: enterToolState(AnimEditorEraseToolState())
//        }
//    }
    
//    private func enterToolState(
//        _ newToolState: AnimEditorToolState
//    ) {
//        toolState?.endState(
//            workspaceVC: workspaceVC,
//            toolControlsVC: toolControlsVC)
//        
//        toolState = newToolState
//        
//        newToolState.beginState(
//            workspaceVC: workspaceVC,
//            toolControlsVC: toolControlsVC)
    }
    
    // MARK: - Frame Editor
    
    private func updateFrameEditor() {
//        guard let toolState else { return }
//        
//        let frameEditor = AnimFrameEditor()
//        frameEditor.delegate = self
//        self.frameEditor = frameEditor
//        
//        let onionSkinConfig: AnimEditorOnionSkinConfig? =
//            state.onionSkinOn ? state.onionSkinConfig : nil
//        
//        frameEditor.begin(
//            projectManifest: state.projectState.projectManifest,
//            sceneManifest: state.sceneManifest,
//            layer: state.layer,
//            layerContent: state.layerContent,
//            frameIndex: state.focusedFrameIndex,
//            onionSkinConfig: onionSkinConfig,
//            editorToolState: toolState)
    }
    
    // MARK: - Frame
    
    private func onFrame() {
//        autoreleasepool {
//            workspaceVC.onFrame()
//            
//            let sceneGraph = frameEditor?.onFrame()
//            if let sceneGraph {
//                // Maybe only set this if it changes?
//                workspaceVC.setContentSize(sceneGraph.contentSize)
//                
//                let viewportSize = workspaceVC.viewportSize()
//                let workspaceTransform = workspaceVC.workspaceTransform()
//                
//                draw(
//                    viewportSize: viewportSize,
//                    workspaceTransform: workspaceTransform,
//                    sceneGraph: sceneGraph)
//            }
//        }
//    }
    
    // MARK: - Render
    
//    private func draw(
//        viewportSize: Size,
//        workspaceTransform: EditorWorkspaceTransform,
//        sceneGraph: EditorWorkspaceSceneGraph
//    ) {
//        guard let drawable = workspaceVC
//            .metalView.metalLayer.nextDrawable()
//        else { return }
//        
//        let commandBuffer = MetalInterface.shared
//            .commandQueue.makeCommandBuffer()!
//        
//        workspaceRenderer.draw(
//            target: drawable.texture,
//            commandBuffer: commandBuffer,
//            viewportSize: viewportSize,
//            workspaceTransform: workspaceTransform,
//            sceneGraph: sceneGraph)
//        
//        commandBuffer.present(drawable)
//        commandBuffer.commit()
//    }
    
    // MARK: - Navigation
    
//    private func dismiss() {
//        dismiss(animated: true)
//    }
    
    // MARK: - Interface
    
//    func update(
//        projectState: ProjectEditManager.State,
//        sceneManifest: Scene.Manifest
//    ) {
//        do {
//            let update = try state.update(
//                projectState: projectState,
//                sceneManifest: sceneManifest)
//
//            applyStateUpdate(update: update)
//
//        } catch {
//            dismiss()
//        }
//    }
    
}

// MARK: - Delegates
/*
extension AnimEditorVC: EditorWorkspaceVC.Delegate {
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}
*/
/*
extension AnimEditorVC: AnimEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: AnimEditorToolbarVC) {
        dismiss()
    }
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC) {
        if state.selectedTool == .paint {
            toolState?.toggleToolExpandedOptionsVisible()
            return
        }
        let update = state.update(selectedTool: .paint)
        applyStateUpdate(update: update)
    }
    
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC) {
        if state.selectedTool == .erase {
            toolState?.toggleToolExpandedOptionsVisible()
            return
        }
        let update = state.update(selectedTool: .erase)
        applyStateUpdate(update: update)
    }
    
    func onSelectToggleOnionSkin(_ vc: AnimEditorToolbarVC) {
        let update = state.update(
            onionSkinOn: !state.onionSkinOn)
        applyStateUpdate(update: update)
    }
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: AnimEditorToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
}
 */

/*
extension AnimEditorVC: AnimEditorTimelineVC.Delegate {
    
    func onChangeDrawerSize(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineVC,
        _ focusedFrameIndex: Int
    ) {
        let update = state.update(
            focusedFrameIndex: focusedFrameIndex)
        
        applyStateUpdate(
            update: update,
            fromTimeline: true)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onRequestCreateDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editBuilder.createDrawing(
//            state: state,
//            frameIndex: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editBuilder.deleteDrawing(
//            state: state,
//            frameIndex: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editBuilder.insertSpacing(
//            state: state,
//            frameIndex: frameIndex)
    }
    
    func onRequestRemoveSpacing(
        _ vc: AnimEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editBuilder.removeSpacing(
//            state: state,
//            frameIndex: frameIndex)
    }
    
    func pendingAssetData(
        _ vc: AnimEditorTimelineVC,
        assetID: String
    ) -> Data? {
        delegate?
            .pendingEditAsset(assetID: assetID)?
            .data
    }
    
}
 */
/*
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
//        try? editBuilder.editDrawing(
//            state: state,
//            drawingID: drawingID,
//            imageSet: imageSet)
    }
    
}
*/
//extension AnimEditorVC: AnimEditorEditBuilder.Delegate {
//    
//    func onRequestSceneEdit(
//        _ b: AnimEditorEditBuilder,
//        sceneEdit: ProjectEditBuilder.SceneEdit
//    ) {
//        delegate?.onRequestSceneEdit(
//            self,
//            sceneEdit: sceneEdit)
//    }
//    
//}

/*
extension AnimEditorVC: AnimEditorAssetLoader.Delegate {
    
    func pendingAssetData(
        _ l: AnimEditorAssetLoader,
        assetID: String
    ) -> Data? {
        delegate?
            .pendingEditAsset(assetID: assetID)?
            .data
    }
    
    func onUpdate(_ l: AnimEditorAssetLoader) {
        frameEditor?.onAssetLoaderUpdate()
    }
    
}
*/
