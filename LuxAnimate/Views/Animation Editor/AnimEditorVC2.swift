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
    
    private let bodyView = AnimEditorView2()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC: AnimEditor2ToolbarVC
    private let timelineVC: AnimEditorTimelineVC
    
    // MARK: - State
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    
    private var contentViewModel: AnimEditorContentViewModel
    private var focusedFrameIndex: Int
    
    // TODO: Onion skin settings
    
    // TODO: Tool state machine
    // TODO: Frame editor
    
    private let assetLoader: AnimEditorAssetLoader
    
    // TODO: Put this in the frame editor and timeline vc.
//    private let editBuilder = AnimEditorEditBuilder()
    
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

        self.focusedFrameIndex = focusedFrameIndex

        toolbarVC = AnimEditor2ToolbarVC()
        
        timelineVC = AnimEditorTimelineVC(
            projectID: projectID)
        
        // TODO: Clamp focused frame index to valid range.
        // Should we pull this logic into a helper function?
        // We'll be doing the same thing in update().
        contentViewModel = try AnimEditorContentViewModel(
            projectID: projectID,
            layerID: layerID,
            projectManifest: projectState.projectManifest,
            sceneManifest: sceneManifest,
            availableUndoCount: projectState.availableUndoCount,
            availableRedoCount: projectState.availableRedoCount)
        
        self.focusedFrameIndex = focusedFrameIndex
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        timelineVC.delegate = self
        
        assetLoader.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDisplayLink()
        
        setupInitialState()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .editorBackground
        
        addChild(workspaceVC,
            to: bodyView.workspaceContainer)
        
        addChild(toolbarVC,
            to: bodyView.toolbarContainer)
        
        addChild(timelineVC,
            to: bodyView.timelineContainer)
        
        workspaceVC.setSafeAreaReferenceView(
            bodyView.workspaceSafeAreaView)
    }
    
    private func setupDisplayLink() {
        displayLink.setCallback { [weak self] _ in
            self?.onFrame()
        }
    }
    
    // MARK: - State
    
    private func setupInitialState() {
        // TODO: Set up initial tool state
        
        // Pass initial state to toolbar, timeline,
        // frame editor
        
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
        setupTestSceneGraph()
    }
    
    private func setupTestSceneGraph() {
        let layer = EditorWorkspaceSceneGraph.Layer(
            content: .rect(.init(color: .white)),
            contentSize: contentSize,
            transform: .identity,
            alpha: 1)
        
        let sceneGraph = EditorWorkspaceSceneGraph(
            contentSize: contentSize,
            layers: [layer])
        
        workspaceVC.setSceneGraph(sceneGraph)
    }
    
    // Shouldn't need all this anymore. We'll have separate
    // paths for updating viewmodel, tool state, and onion
    // skin settings. No need to check for "changes". And
    // no need to check where the update originated from -
    // child view controllers will account for that with
    // internal flags when they propagate updates.
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
        // We don't care about edit context anymore.
        // The child view controllers will manage that.
        
        // When we receive an update, we should update our
        // own state and pass it to all children.
        
        // I also don't think we need this "update" method
        // on the state/viewmodel. We can just regenerate it
        // from scratch. Because the focusedFrameIndex and
        // onion skin options are factored out of the
        // content viewmodel now, their updates should
        // happen through different paths.
        
        // TODO: Generate content viewmodel from input.
        // If generation fails, dismiss this view.
        // Pass updated viewmodel to children.
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
        // TODO: Update tool state machine, update frame editor.
    }
    
}

extension AnimEditorVC2: AnimEditorTimelineVC.Delegate {
    
    func onChangeDrawerSize(
        _ vc: AnimEditorTimelineVC
    ) {
        view.layoutIfNeeded()
    }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineVC,
        _ focusedFrameIndex: Int
    ) {
        // TODO: Update focused frame index, clamping to
        // allowed values. Propagate change to child vcs,
        // including timeline vc.
        
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
    
    // TODO: Consolidate these four methods into a single
    // 'apply edit' method. Timeline vc should be
    // responsible for creating the edit objects.
    
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
