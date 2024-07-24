//
//  AnimationEditorVC.swift
//

import UIKit

protocol AnimationEditorVCDelegate: AnyObject {
        
    func onRequestUndo(_ vc: SceneEditorVC)
    func onRequestRedo(_ vc: SceneEditorVC)
    
    func onRequestApplyEdit(
        _ vc: SceneEditorVC,
        layerID: String,
        newAnimationLayerContent: Scene.AnimationLayerContent,
        newAssets: [ProjectEditor.Asset])
    
}

class AnimationEditorVC: UIViewController {
    
    weak var delegate: AnimationEditorVCDelegate?
    
    private let timelineVC = AnimationEditorTimelineVC()
    private let frameVC: EditorFrameVC
    
    private let projectID: String
    private let layerID: String
    
    private var animationLayerContent: Scene.AnimationLayerContent
    
    // MARK: - Init
    
    init(
        projectID: String,
        layerID: String,
        projectViewportSize: PixelSize,
        layerContentSize: PixelSize,
        animationLayerContent: Scene.AnimationLayerContent
    ) throws {
        
        self.projectID = projectID
        self.layerID = layerID
        
        self.animationLayerContent = animationLayerContent
        
        frameVC = try EditorFrameVC(
            projectID: projectID,
            projectViewportSize: projectViewportSize,
            layerContentSize: layerContentSize)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setInitialData()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        frameVC.delegate = self
        timelineVC.delegate = self
        
        addChild(frameVC, to: view)
        addChild(timelineVC, to: view)
        
        frameVC.setBottomInsetView(
            timelineVC.contentAreaView)
    }
    
    // MARK: - Data
    
    private func setInitialData() {
//        let projectManifest = editor.currentProjectManifest
//        
//        update(
//            projectManifest: projectManifest,
//            editContext: nil)
//        
//        timelineVC.setFocusedFrameIndex(0)
//        frameVC.setFocusedFrameIndex(0)
    }
    
    private func update(
        projectManifest: Project.Manifest,
        editContext: Any?
    ) {
//        model = modelGenerator.generate(
//            from: projectManifest)
//        
//        focusedFrameIndex = clamp(
//            focusedFrameIndex,
//            min: 0,
//            max: model.frames.count - 1)
//        
//        timelineVC.setModel(model)
//        timelineVC.setFocusedFrameIndex(focusedFrameIndex)
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
//        focusedFrameIndex = index
        frameVC.setFocusedFrameIndex(index)
        
//        playbackController.stopPlayback()
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
//        try? editor.applyUndo()
    }
    
    func onSelectRedo(_ vc: EditorFrameVC) {
//        try? editor.applyRedo()
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

// MARK: - Editor Delegate

/*
extension AnimationEditorVC: ProjectContentEditorDelegate {
    
    func onEditProject(
        _ editor: ProjectContentEditor,
        editContext: Any?
    ) {
        let projectManifest = editor.currentProjectManifest
        update(
            projectManifest: projectManifest,
            editContext: editContext)
    }
    
}
*/
