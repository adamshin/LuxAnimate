//
//  NewAnimationEditorVC.swift
//

import UIKit

protocol NewAnimationEditorVCDelegate: AnyObject {
        
    func onRequestUndo(_ vc: NewAnimationEditorVC)
    func onRequestRedo(_ vc: NewAnimationEditorVC)
    
    // TODO: Allow specifying synchronous vs asynchronous edits!
    func onRequestApplyEdit(
        _ vc: NewAnimationEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class NewAnimationEditorVC: UIViewController {
    
    weak var delegate: NewAnimationEditorVCDelegate?
    
    private let bodyView = NewAnimationEditorView()
    
    private let drawingEditorVC = DrawingEditorVC()
    private let toolbarVC = NewAnimationEditorToolbarVC()
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    private let frameIndex: Int
    
    // MARK: - Initializer
    
    init(
        projectID: String,
        sceneID: String,
        layerID: String,
        frameIndex: Int
    ) throws {
        self.projectID = projectID
        self.sceneID = sceneID
        self.layerID = layerID
        self.frameIndex = frameIndex
        
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
        
        drawingEditorVC.delegate = self
        toolbarVC.delegate = self
        
        addChild(drawingEditorVC, to: bodyView.canvasContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        
        drawingEditorVC.setSafeAreaReferenceView(
            bodyView.canvasOverlayContainer)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        // todo
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

extension NewAnimationEditorVC: DrawingEditorVCDelegate {
    
    func onSelectUndo(_ vc: DrawingEditorVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: DrawingEditorVC) {
        delegate?.onRequestRedo(self)
    }
    
}

extension NewAnimationEditorVC: NewAnimationEditorToolbarVCDelegate {
    
    func onSelectBack(_ vc: NewAnimationEditorToolbarVC) {
        dismiss(animated: true)
    }
    
    func onSelectBrushTool(_ vc: NewAnimationEditorToolbarVC) {
//        frameEditorVC.selectBrushTool()
    }
    func onSelectEraseTool(_ vc: NewAnimationEditorToolbarVC) {
//        frameEditorVC.selectEraseTool()
    }
    
    func onSelectUndo(_ vc: NewAnimationEditorToolbarVC) {
        delegate?.onRequestUndo(self)
    }
    func onSelectRedo(_ vc: NewAnimationEditorToolbarVC) {
        delegate?.onRequestRedo(self)
    }
    
}
