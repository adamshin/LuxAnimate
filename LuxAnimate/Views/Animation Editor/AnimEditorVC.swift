//
//  AnimEditorVC2.swift
//

import UIKit
import Geometry

private let contentSize = Size(
    width: 1920, height: 1080)

extension AnimEditorVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onRequestUndo(_ vc: AnimEditorVC)
        func onRequestRedo(_ vc: AnimEditorVC)
        
        func onRequestSceneEdit(
            _ vc: AnimEditorVC,
            sceneEdit: ProjectEditBuilder.SceneEdit)
        
        func pendingEditAsset(
            _ vc: AnimEditorVC,
            assetID: String
        ) -> ProjectEditManager.NewAsset?
        
    }
    
}

class AnimEditorVC: UIViewController {
    
    // MARK: - View
    
    private let bodyView = AnimEditorView()
    
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
        
        // TODO: Clamp focused frame index to valid range.
        // Should we pull this logic into a helper function?
        // We'll be doing the same thing in update().
        self.contentViewModel = try AnimEditorContentViewModel(
            projectManifest: projectState.projectManifest,
            sceneManifest: sceneManifest,
            layerID: layerID,
            availableUndoCount: projectState.availableUndoCount,
            availableRedoCount: projectState.availableRedoCount)
        
        toolbarVC = AnimEditor2ToolbarVC()
        
        timelineVC = AnimEditorTimelineVC(
            projectID: projectID,
            contentViewModel: contentViewModel,
            focusedFrameIndex: focusedFrameIndex)
        
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
        setupTestSceneGraph()
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
    
    private func setupInitialState() {
        toolbarVC.update(contentViewModel: contentViewModel)
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
    
    // MARK: - Internal State
    
    private func internalSetFocusedFrameIndex(_ i: Int) {
        let frameCount =
            contentViewModel.sceneManifest.frameCount
        
        focusedFrameIndex = clamp(i,
            min: 0,
            max: frameCount - 1)
        
        timelineVC.update(
            focusedFrameIndex: focusedFrameIndex)
    }
    
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
        sceneManifest: Scene.Manifest
    ) {
        do {
            contentViewModel = try AnimEditorContentViewModel(
                projectManifest: projectState.projectManifest,
                sceneManifest: sceneManifest,
                layerID: layerID,
                availableUndoCount: projectState.availableUndoCount,
                availableRedoCount: projectState.availableRedoCount)
            
            let frameCount =
                contentViewModel.sceneManifest.frameCount
            
            focusedFrameIndex = clamp(focusedFrameIndex,
                min: 0,
                max: frameCount - 1)
            
            toolbarVC.update(contentViewModel: contentViewModel)
            timelineVC.update(contentViewModel: contentViewModel)
            
            timelineVC.update(focusedFrameIndex: focusedFrameIndex)
            
        } catch {
            dismiss()
        }
    }
    
}

// MARK: - Delegates

extension AnimEditorVC: EditorWorkspaceVC.Delegate {
    
    func onSelectUndo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: EditorWorkspaceVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension AnimEditorVC: AnimEditor2ToolbarVC.Delegate {
    
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

extension AnimEditorVC: AnimEditorTimelineVC.Delegate {
    
    func onChangeDrawerSize(
        _ vc: AnimEditorTimelineVC
    ) {
        view.layoutIfNeeded()
    }
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineVC,
        _ focusedFrameIndex: Int
    ) {
        internalSetFocusedFrameIndex(focusedFrameIndex)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onRequestSceneEdit(
        _ vc: AnimEditorTimelineVC,
        sceneEdit: ProjectEditBuilder.SceneEdit
    ) {
        delegate?.onRequestSceneEdit(
            self, sceneEdit: sceneEdit)
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

extension AnimEditorVC: AnimEditorAssetLoader.Delegate {
    
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
