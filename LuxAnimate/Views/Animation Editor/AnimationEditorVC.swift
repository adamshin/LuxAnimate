//
//  AnimationEditorVC.swift
//

import UIKit

protocol AnimationEditorVCDelegate: AnyObject {
        
    func onRequestUndo(_ vc: AnimationEditorVC)
    func onRequestRedo(_ vc: AnimationEditorVC)
    
    // TODO: Allow specifying synchronous vs asynchronous edits!
    func onRequestApplyEdit(
        _ vc: AnimationEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class AnimationEditorVC: UIViewController {
    
    weak var delegate: AnimationEditorVCDelegate?
    
    private let timelineVC: AnimationEditorTimelineVC
    private let frameVC: AnimationFrameVC
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    private let initialFrameIndex: Int
    
    private let editor: AnimationLayerEditor
    
    private var projectManifest: Project.Manifest?
    private var sceneManifest: Scene.Manifest?
    private var animationLayerContent: Scene.AnimationLayerContent?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        layerID: String,
        initialFrameIndex: Int
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.layerID = layerID
        self.initialFrameIndex = initialFrameIndex
        
        timelineVC = AnimationEditorTimelineVC()
        frameVC = try AnimationFrameVC(projectID: projectID)
        
        editor = AnimationLayerEditor(layerID: layerID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        editor.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        timelineVC.delegate = self
        frameVC.delegate = self
        
        addChild(frameVC, to: view)
        addChild(timelineVC, to: view)
        
        frameVC.setBottomInsetView(
            timelineVC.contentAreaView)
        
        timelineVC.setFocusedFrameIndex(initialFrameIndex)
        frameVC.setFocusedFrameIndex(initialFrameIndex)
        
        timelineVC.setExpanded(true)
    }
    
    // MARK: - Data
    
    private func shit() {}
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest
    ) {
        guard 
            let layer = sceneManifest.layers
                .first(where: { $0.id == layerID }),
            case .animation(let animationLayerContent)
                = layer.content
        else {
            dismiss(animated: true)
            return
        }
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.animationLayerContent = animationLayerContent
        
        editor.update(animationLayerContent: animationLayerContent)
        
        timelineVC.update(
            projectID: projectID,
            sceneManifest: sceneManifest,
            animationLayerContent: animationLayerContent)
        
//        frameVC.setProjectManifest(
//            projectManifest,
//            editContext: editContext)
//        frameVC.setFocusedFrameIndex(focusedFrameIndex)
    }
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        frameVC.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
    }
    
}

// MARK: - View Controller Delegates

extension AnimationEditorVC: AnimationTimelineVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: AnimationEditorTimelineVC,
        index: Int
    ) {
        frameVC.setFocusedFrameIndex(index)
    }
    
    func onSelectPlayPause(
        _ vc: AnimationEditorTimelineVC
    ) { }
    
    func onRequestCreateDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
        editor.createDrawing(at: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
        editor.deleteDrawing(at: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: AnimationEditorTimelineVC, 
        frameIndex: Int
    ) {
        editor.insertSpacing(at: frameIndex)
    }
    
    func onRequestRemoveSpacing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
        editor.removeSpacing(at: frameIndex)
    }
    
    func onChangeContentAreaSize(
        _ vc: AnimationEditorTimelineVC
    ) {
        frameVC.handleChangeBottomInsetViewFrame()
    }
    
}

extension AnimationEditorVC: AnimationFrameVCDelegate {
    
    func onSelectBack(_ vc: AnimationFrameVC) {
        dismiss(animated: true)
    }
    
    func onSelectUndo(_ vc: AnimationFrameVC) {
        delegate?.onRequestUndo(self)
    }
    
    func onSelectRedo(_ vc: AnimationFrameVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onEditDrawing(
        _ vc: AnimationFrameVC,
        drawingID: String,
        drawingTexture: MTLTexture
    ) {
//        editor.editDrawing(
//            drawingID: drawingID,
//            drawingTexture: drawingTexture)
    }
    
}

extension AnimationEditorVC: AnimationLayerEditorDelegate {
    
    func onRequestApplyEdit(
        _ editor: AnimationLayerEditor,
        edit: AnimationLayerEditor.Edit
    ) {
        guard let sceneManifest,
            let layerIndex = sceneManifest.layers
                .firstIndex(where: { $0.id == layerID })
        else { return }
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers[layerIndex].content
            = .animation(edit.newAnimationLayerContent)
        
        self.sceneManifest = newSceneManifest
        self.animationLayerContent = edit.newAnimationLayerContent
        
        timelineVC.update(
            projectID: projectID,
            sceneManifest: self.sceneManifest!,
            animationLayerContent: self.animationLayerContent!)
        
        // TODO: Update frame vc
        
        delegate?.onRequestApplyEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: edit.newAssets)
    }
    
}
