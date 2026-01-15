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
        
        func onRequestEdit(
            _ vc: AnimEditorVC,
            layer: Scene.Layer,
            layerContentEdit: AnimationLayerContentEditBuilder.Edit)
        
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
    private let workspaceControlsContainerVC
        = PassthroughContainerViewController()
    
    private let toolbarVC: AnimEditor2ToolbarVC
    private let timelineVC: AnimEditorTimelineVC
    
    // MARK: - State
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    
    private var model: AnimEditorModel
    private var focusedFrameIndex: Int
    
    // TODO: Onion skin settings
    
    private let toolStateMachine = AnimEditorToolStateMachine()
    private let frameEditor = AnimFrameEditor()
    
    private let assetLoader: AnimEditorAssetLoader
    
    private let displayLink = WrappedDisplayLink()
    
    // MARK: - Delegate
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        layerID: String,
        sceneEditorModel: SceneEditorModel,
        focusedFrameIndex: Int
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.layerID = layerID
        
        let model = try Self.createModel(
            sceneEditorModel: sceneEditorModel,
            layerID: layerID)
        
        self.model = model
        
        self.focusedFrameIndex = Self.clampedFrameIndex(
            index: focusedFrameIndex,
            model: model)
        
        toolbarVC = AnimEditor2ToolbarVC()
        
        timelineVC = AnimEditorTimelineVC(
            projectID: projectID,
            model: model,
            focusedFrameIndex: focusedFrameIndex)
        
        assetLoader = AnimEditorAssetLoader(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        timelineVC.delegate = self
        
        toolStateMachine.delegate = self
        frameEditor.delegate = self
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
        addChild(
            workspaceVC,
            to: bodyView.workspaceContainer)
        addChild(
            workspaceControlsContainerVC,
            to: bodyView.workspaceSafeAreaView)
        
        addChild(
            toolbarVC,
            to: bodyView.toolbarContainer)
        addChild(
            timelineVC,
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
        toolbarVC.update(model: model)
        toolbarVC.update(selectedTool: .paint)
        
        toolStateMachine.setToolState(
            AnimEditorPaintToolState())
        
        updateFrameEditor()
    }
    
    // MARK: - Internal State
    
    private func updateInternal(
        sceneEditorModel: SceneEditorModel
    ) {
        do {
            model = try Self.createModel(
                sceneEditorModel: sceneEditorModel,
                layerID: layerID)
            
            focusedFrameIndex = Self.clampedFrameIndex(
                index: focusedFrameIndex,
                model: model)
            
            toolbarVC.update(model: model)
            
            timelineVC.update(model: model)
            timelineVC.update(
                focusedFrameIndex: focusedFrameIndex)
            
            updateFrameEditor()
            
        } catch {
            dismiss()
        }
    }
    
    private func updateInternal(
        selectedToolbarTool tool: AnimEditor2ToolbarVC.Tool
    ) {
        let toolState: AnimEditorToolState = switch tool {
        case .paint: AnimEditorPaintToolState()
        case .erase: AnimEditorPaintToolState()
        }
        
        toolStateMachine.setToolState(toolState)
        
        updateFrameEditor()
    }
    
    private func updateInternal(
        focusedFrameIndex newFocusedFrameIndex: Int
    ) {
        focusedFrameIndex = Self.clampedFrameIndex(
            index: newFocusedFrameIndex,
            model: model)
        
        timelineVC.update(
            focusedFrameIndex: focusedFrameIndex)
        
        updateFrameEditor()
    }
    
    private func updateFrameEditor() {
        frameEditor.update(
            model: model,
            focusedFrameIndex: focusedFrameIndex,
            editorToolState: toolStateMachine.toolState)
    }
    
    // MARK: - Frame
    
    private func onFrame() {
        let sceneGraph = frameEditor.onFrame()
        
        if let sceneGraph {
            workspaceVC.setSceneGraph(sceneGraph)
        }
        workspaceVC.onFrame()
    }
    
    // MARK: - Navigation
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    // MARK: - Interface
    
    func update(sceneEditorModel: SceneEditorModel) {
        updateInternal(sceneEditorModel: sceneEditorModel)
    }
    
}

// MARK: - Helpers

extension AnimEditorVC {
    
    private static func createModel(
        sceneEditorModel sm: SceneEditorModel,
        layerID: String
    ) throws -> AnimEditorModel {
        
        try AnimEditorModel(
            projectManifest: sm.projectManifest,
            sceneManifest: sm.sceneManifest,
            layerID: layerID,
            availableUndoCount: sm.availableUndoCount,
            availableRedoCount: sm.availableRedoCount)
    }
    
    private static func clampedFrameIndex(
        index: Int, model: AnimEditorModel
    ) -> Int {
        let frameCount = model.sceneManifest.frameCount
        return clamp(index, min: 0, max: frameCount - 1)
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
        // TODO: If tool is already selected, toggle
        // expanded tool UI.
        
        updateInternal(selectedToolbarTool: tool)
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
        updateInternal(focusedFrameIndex: focusedFrameIndex)
    }
    
    func onSelectPlayPause(
        _ vc: AnimEditorTimelineVC
    ) { }
    
    func onRequestEdit(
        _ vc: AnimEditorTimelineVC,
        layerContentEdit: AnimationLayerContentEditBuilder.Edit
    ) {
        delegate?.onRequestEdit(
            self,
            layer: model.layer,
            layerContentEdit: layerContentEdit)
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
        frameEditor.onAssetLoaderUpdate()
    }
    
}

extension AnimEditorVC:
    AnimEditorToolStateMachine.Delegate {
    
    func toolStateDidEnd(
        _ machine: AnimEditorToolStateMachine
    ) {
        workspaceVC.removeAllOverlayGestureRecognizers()
        workspaceControlsContainerVC.show(nil)
    }
    
    func toolStateDidBegin(
        _ machine: AnimEditorToolStateMachine,
        workspaceControlsVC: UIViewController?,
        workspaceGestureRecognizers: [UIGestureRecognizer]
    ) {
        for g in workspaceGestureRecognizers {
            workspaceVC.addOverlayGestureRecognizer(g)
        }
        
        workspaceControlsContainerVC
            .show(workspaceControlsVC)
    }
    
}

extension AnimEditorVC: AnimFrameEditor.Delegate {
    
    func workspaceViewSize(_ e: AnimFrameEditor)
    -> Size {
        Size(workspaceVC.view.bounds.size)
    }
    
    func workspaceTransform(_ e: AnimFrameEditor)
    -> EditorWorkspaceTransform {
        workspaceVC.workspaceTransform()
    }
    
    func onRequestLoadAssets(
        _ e: AnimFrameEditor, assetIDs: Set<String>
    ) {
        assetLoader.update(assetIDs: assetIDs)
    }
    
    func hasLoadedAssets(
        _ e: AnimFrameEditor, assetIDs: Set<String>
    ) -> Bool {
        let loadedAssetIDs = assetLoader.loadedAssets.keys
        return assetIDs.isSubset(of: loadedAssetIDs)
    }
    
    func asset(
        _ e: AnimFrameEditor, assetID: String
    ) -> AnimEditorAssetLoader.LoadedAsset? {
        assetLoader.loadedAssets[assetID]
    }
    
    func onRequestEdit(
        _ e: AnimFrameEditor,
        drawingID: String,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        let imageSet = AnimationLayerContentEditBuilder
            .DrawingImageSet(
                full: imageSet.full,
                thumbnail: imageSet.thumbnail)
        
        do {
            let layerContentEdit = try
                AnimationLayerContentEditBuilder
                    .editDrawing(
                        layerContent: model.layerContent,
                        drawingID: drawingID,
                        imageSet: imageSet)
            
            delegate?.onRequestEdit(
                self,
                layer: model.layer,
                layerContentEdit: layerContentEdit)
            
        } catch { }
    }
    
}
