//
//  AnimationEditorVC.swift
//

import UIKit

protocol AnimationEditorVCDelegate: AnyObject {
        
    func onRequestUndo(_ vc: AnimationEditorVC)
    func onRequestRedo(_ vc: AnimationEditorVC)
    
    func onRequestApplyEdit(
        _ vc: SceneEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class AnimationEditorVC: UIViewController {
    
    weak var delegate: AnimationEditorVCDelegate?
    
    private let timelineVC: AnimationEditorTimelineVC
    private let frameVC: EditorFrameVC
    
    private let projectID: String
    private let sceneID: String
    private let layerID: String
    private let initialFrameIndex: Int
    
    private var projectManifest: Project.Manifest?
    private var sceneManifest: Scene.Manifest?
    
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
        frameVC = try EditorFrameVC(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
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
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        availableUndoCount: Int,
        availableRedoCount: Int
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
        
        timelineVC.update(
            projectID: projectID,
            sceneManifest: sceneManifest,
            animationLayerContent: animationLayerContent)
        
        frameVC.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
//
//        frameVC.setProjectManifest(
//            projectManifest,
//            editContext: editContext)
//        frameVC.setFocusedFrameIndex(focusedFrameIndex)
//        
//        playbackController.setModel(model)
    }
    
}

// MARK: - View Controller Delegates

extension AnimationEditorVC: AnimationEditorTimelineVCDelegate {
    
    func onBeginFrameScroll(_ vc: AnimationEditorTimelineVC) {
        frameVC.onBeginFrameScroll()
    }
    
    func onEndFrameScroll(_ vc: AnimationEditorTimelineVC) {
        frameVC.onEndFrameScroll()
    }
    
    func onChangeFocusedFrame(
        _ vc: AnimationEditorTimelineVC,
        index: Int
    ) {
        frameVC.setFocusedFrameIndex(index)
    }
    
    func onSelectPlayPause(
        _ vc: AnimationEditorTimelineVC
    ) {
//        if playbackController.isPlaying {
//            playbackController.stopPlayback()
//        } else {
//            playbackController.startPlayback(
//                frameIndex: focusedFrameIndex)
//        }
    }
    
    func onRequestCreateDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editor.createEmptyDrawing(
//            frameIndex: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editor.deleteDrawing(at: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: AnimationEditorTimelineVC, 
        frameIndex: Int
    ) {
//        try? editor.insertSpacing(at: frameIndex)
    }
    
    func onRequestRemoveSpacing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int
    ) {
//        try? editor.removeSpacing(at: frameIndex)
    }
    
    func onChangeContentAreaSize(
        _ vc: AnimationEditorTimelineVC
    ) {
        frameVC.handleChangeBottomInsetViewFrame()
    }
    
}

extension AnimationEditorVC: EditorFrameVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameVC) {
        dismiss(animated: true)
    }
    
    func onSelectUndo(_ vc: EditorFrameVC) {
        delegate?.onRequestUndo(self)
    }
    
    func onSelectRedo(_ vc: EditorFrameVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        drawingTexture: MTLTexture,
        editContext: Any?
    ) {
//        try? editor.editDrawing(
//            drawingID: drawingID,
//            drawingTexture: drawingTexture,
//            editContext: editContext)
    }
    
}
