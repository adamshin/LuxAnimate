//
//  NewAnimationEditorVC.swift
//

import UIKit

protocol NewAnimationEditorVCDelegate: AnyObject {
        
    func onRequestUndo(_ vc: NewAnimationEditorVC)
    func onRequestRedo(_ vc: NewAnimationEditorVC)
    
    // TODO: Allow specifying synchronous vs asynchronous edits?
    func onRequestApplyEdit(
        _ vc: NewAnimationEditorVC,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class NewAnimationEditorVC: UIViewController {
    
    weak var delegate: NewAnimationEditorVCDelegate?
    
    private let bodyView = NewAnimationEditorView()
    
    private let workspaceVC = EditorWorkspaceVC()
    private let toolbarVC = NewAnimationEditorToolbarVC()
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    
    private var frameEditor: AnimationFrameEditor?
    
    // MARK: - Initializer
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int
    ) {
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workspaceVC.delegate = self
        toolbarVC.delegate = self
        
        addChild(workspaceVC, to: bodyView.workspaceContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        
//        canvasVC.setSafeAreaReferenceView(
//            bodyView.canvasOverlayContainer)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Rendering
    
    private func drawWorkspace() {
//        frameEditor?.drawViewport()
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        frameEditor = AnimationFrameEditor(
            projectID: projectID,
            sceneID: sceneID,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinPrevCount: 0,
            onionSkinNextCount: 0,
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            delegate: self)
    }
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        toolbarVC.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
    }
    
}

// MARK: - Delegates

extension NewAnimationEditorVC: EditorWorkspaceVCDelegate {
    
    func onRequestDraw(_ vc: EditorWorkspaceVC) {
        // TODO: Trigger render
    }
    
}

extension NewAnimationEditorVC: NewAnimationEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: NewAnimationEditorToolbarVC) {
        dismiss(animated: true)
    }
    
    func onSelectBrushTool(_ vc: NewAnimationEditorToolbarVC) { }
    func onSelectEraseTool(_ vc: NewAnimationEditorToolbarVC) { }
    
    func onSelectUndo(_ vc: NewAnimationEditorToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: NewAnimationEditorToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension NewAnimationEditorVC: AnimationFrameEditorDelegate {
    
    func onFinishLoadingAssets(
        _ editor: AnimationFrameEditor
    ) {
        drawWorkspace()
    }
    
    func onUpdateViewportTexture(
        _ session: AnimationFrameEditor,
        viewportTexture: MTLTexture
    ) {
//        canvasVC.setCanvasTexture(viewportTexture)
    }
    
    func onRequestApplyEdit(
        _ session: AnimationFrameEditor,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) {
        // TODO
    }
    
}
