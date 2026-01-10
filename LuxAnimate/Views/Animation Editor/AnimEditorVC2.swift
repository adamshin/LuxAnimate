//
//  AnimEditorVC2.swift
//

import UIKit
import Geometry

private let contentSize = Size(
    width: 1920, height: 1080)

struct AnimEditorVCEditContext2 {
    var sender: AnimEditorVC2
    var isFromFrameEditor: Bool
}

extension AnimEditorVC2 {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestUndo(_ vc: AnimEditorVC2)
        func onRequestRedo(_ vc: AnimEditorVC2)
        
        func onRequestSceneEdit(
            _ vc: AnimEditorVC2,
            sceneEdit: ProjectEditBuilder.SceneEdit,
            editContext: Sendable?)
        
        func pendingEditAsset(
            _ vc: AnimEditorVC2,
            assetID: String
        ) -> ProjectEditManager.NewAsset?
        
    }
    
}

class AnimEditorVC2: UIViewController {
    
    // MARK: - View
    
    private let workspaceVC = EditorWorkspaceVC()
    
    private let toolbarVC: AnimEditor2ToolbarVC
    private let timelineVC: AnimEditorTimelineVC
    
    // TODO: Do we need a frame vc? Maybe all frame editing
    // logic should live in a non-view object, like
    // AnimFrameEditor.
//    private let frameVC: AnimEditorFrameVC
    
    // MARK: - State
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    
    // TODO: Reevaluate this. Should maybe be a view model,
    // with a bit less data.
//    private var state: AnimEditorState
    
    // TODO: Create tool state machine to manage this
//    private var toolState: AnimEditorToolState?
    
//    private var frameEditor: AnimFrameEditor?
    
    // This makes sense here.
    private let assetLoader: AnimEditorAssetLoader
    
    // Should this be here, or in the frame editor? And the
    // frame editor passes complete edit objects to us? See
    // comments below. I don't think this class should have
    // to know about all the possible types of edits that
    // can happen. There will only be more and more.
//    private let editBuilder = AnimEditorEditBuilder()
    
    // This can stay.
    private let displayLink = WrappedDisplayLink()
    
    // MARK: - Delegate
    
    weak var delegate: Delegate?
    
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
        
        toolbarVC = AnimEditor2ToolbarVC()
        
        timelineVC = AnimEditorTimelineVC(
            projectID: projectID)
        
//        frameVC = AnimEditorFrameVC()
        
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
        
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        timelineVC.delegate = self
        
        assetLoader.delegate = self
//        editBuilder.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDisplayLink()
        
        setInitialState()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .editorBackground
        
        addChild(workspaceVC, to: view)
        
        // TODO: Add toolbar. maybe needs a
        // remainderContentView like other views?
        
        addChild(timelineVC, to: view)
        
//        addChild(frameVC,
//            to: timelineVC.remainderContentView)
        
        // TODO: We need to set up a new view for this.
        // Just a view that spans between the toolbar and
        // timeline area.
        
//        workspaceVC.setSafeAreaReferenceView(
//            frameVC.contentAreaView)
    }
    
    private func setupDisplayLink() {
        displayLink.setCallback { [weak self] _ in
            self?.onFrame()
        }
    }
    
    // MARK: - State
    
    private func setInitialState() {
//        toolbarVC.update(
//            projectState: state.projectState)
//        toolbarVC.update(
//            selectedTool: state.selectedTool)
        
//        timelineVC.update(
//            timelineModel: state.timelineModel)
//        timelineVC.update(
//            focusedFrameIndex: state.focusedFrameIndex)
        
//        frameVC.update(
//            projectState: state.projectState)
        
//        updateToolState(
//            selectedTool: state.selectedTool)
        
//        updateFrameEditor()
        
        // TESTING
        setInitialSceneGraph()
    }
    
    private func setInitialSceneGraph() {
        let sceneGraph = EditorWorkspaceSceneGraph(
            contentSize: contentSize,
            layers: [
                .init(
                    content: .rect(.init(color: .white)),
                    contentSize: contentSize,
                    transform: .identity,
                    alpha: 1)
            ])
        
        workspaceVC.setSceneGraph(sceneGraph)
    }
    
    /*
    private func applyStateUpdate(
        update: AnimEditorState.Update,
        fromFrameEditor: Bool = false,
        fromTimeline: Bool = false
    ) {
        let state = update.state
        let changes = update.changes
        
        self.state = state
        
        if changes.projectState {
            frameVC.update(
                projectState: state.projectState)
        }
        if changes.selectedTool {
//            toolbarVC.update(
//                selectedTool: state.selectedTool)
        }
        if changes.onionSkin {
//            toolbarVC.update(
//                onionSkinOn: state.onionSkinOn)
        }
        
        if !fromTimeline, changes.timelineModel {
            timelineVC.update(
                timelineModel: state.timelineModel)
        }
        if !fromTimeline, changes.focusedFrameIndex {
            timelineVC.update(
                focusedFrameIndex: state.focusedFrameIndex)
        }
        
        if changes.selectedTool {
//            updateToolState(
//                selectedTool: state.selectedTool)
        }
        
        if !fromFrameEditor,
            changes.projectState ||
            changes.focusedFrameIndex ||
            changes.onionSkin ||
            changes.selectedTool
        {
            updateFrameEditor()
        }
    }
     */
    
    // MARK: - Tool State
    
//    private func updateToolState(
//        selectedTool: AnimEditorState.Tool
//    ) {
//        switch selectedTool {
//        case .paint: enterToolState(AnimEditorPaintToolState())
//        case .erase: enterToolState(AnimEditorEraseToolState())
//        }
//    }
//    
//    private func enterToolState(
//        _ newToolState: AnimEditorToolState
//    ) {
//        toolState?.endState(
//            workspaceVC: workspaceVC,
//            workspaceControlsVC: workspaceControlsVC)
//        
//        toolState = newToolState
//        
//        newToolState.beginState(
//            workspaceVC: workspaceVC,
//            workspaceControlsVC: workspaceControlsVC)
//    }
    
    // MARK: - Frame Editor
    
    /*
    private func updateFrameEditor() {
        guard let toolState else { return }
        
        let frameEditor = AnimFrameEditor()
//        frameEditor.delegate = self
        self.frameEditor = frameEditor
        
        let onionSkinConfig: AnimEditorOnionSkinConfig? =
            state.onionSkinOn ? state.onionSkinConfig : nil
        
        frameEditor.begin(
            projectManifest: state.projectState.projectManifest,
            sceneManifest: state.sceneManifest,
            layer: state.layer,
            layerContent: state.layerContent,
            frameIndex: state.focusedFrameIndex,
            onionSkinConfig: onionSkinConfig,
            editorToolState: toolState)
    }
     */
    
    // MARK: - Frame
    
    private func onFrame() {
        workspaceVC.onFrame()
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
        /*
        let fromFrameEditor: Bool =
            if let context = editContext
                as? AnimEditorVCEditContext2,
                context.sender == self,
                context.isFromFrameEditor
            { true } else { false }
        
        do {
            let update = try state.update(
                projectState: projectState,
                sceneManifest: sceneManifest)
            
            applyStateUpdate(
                update: update,
                fromFrameEditor: fromFrameEditor)
            
        } catch {
            dismiss()
        }
         */
    }
    
}

// MARK: - Delegates

extension AnimEditorVC2: EditorWorkspaceVC.Delegate {
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC2: AnimEditor2ToolbarVC.Delegate {
    
    func onSelectBack(_ vc: AnimEditor2ToolbarVC) {
        dismiss()
    }
    
    func onSelectUndo(_ vc: AnimEditor2ToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: AnimEditor2ToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onSelectTool(
        _ vc: AnimEditor2ToolbarVC,
        tool: AnimEditor2ToolbarVC.Tool,
        isAlreadySelected: Bool
    ) {
        // TODO: Update state machine, update frame editor.
    }
    
}

/*
extension AnimEditorVC2: AnimEditorFrameVC.Delegate {
    
    func onSelectBack(_ vc: AnimEditorFrameVC) {
        dismiss()
    }
    
    func onRequestUndo(_ vc: AnimEditorFrameVC) {
        delegate?.onRequestUndo(self)
    }
    func onRequestRedo(_ vc: AnimEditorFrameVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onSelectTool(
        _ vc: AnimEditorFrameVC,
        tool: AnimEditorFrameVC.Tool
    ) {
        // TODO: Handle tool selection
    }
    
    func onRequestSceneEdit(
        _ vc: AnimEditorFrameVC,
        sceneEdit: ProjectEditBuilder.SceneEdit,
        editContext: Sendable?
    ) { }
    
    func pendingEditAsset(
        _ vc: AnimEditorFrameVC,
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        nil
    }
    
}
 */

extension AnimEditorVC2: AnimEditorTimelineVC.Delegate {
    
    func onChangeDrawerSize(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineVC,
        _ focusedFrameIndex: Int
    ) {
//        let update = state.update(
//            focusedFrameIndex: focusedFrameIndex)
//        
//        applyStateUpdate(
//            update: update,
//            fromTimeline: true)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    // TODO: Consolidate these methods into a single
    // 'apply edit' method?
    
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
            .pendingEditAsset(self, assetID: assetID)?
            .data
    }
    
}

/*
extension AnimEditorVC2: AnimFrameEditor.Delegate {
    
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
        let editContext = AnimEditorVCEditContext2(
            sender: self,
            isFromFrameEditor: true)
        
        try? editBuilder.editDrawing(
            state: state,
            drawingID: drawingID,
            imageSet: imageSet,
            editContext: editContext)
    }
    
}
 */

extension AnimEditorVC2: AnimEditorEditBuilder.Delegate {
    
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

extension AnimEditorVC2: AnimEditorAssetLoader.Delegate {
    
    func pendingAssetData(
        _ l: AnimEditorAssetLoader,
        assetID: String
    ) -> Data? {
        delegate?
            .pendingEditAsset(self, assetID: assetID)?
            .data
    }
    
    func onUpdate(_ l: AnimEditorAssetLoader) {
//        frameEditor?.onAssetLoaderUpdate()
    }
    
}
