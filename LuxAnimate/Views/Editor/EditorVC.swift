//
//  EditorVC.swift
//

import UIKit
import PhotosUI

class EditorVC: UIViewController {
    
    private let timelineVC = EditorTimelineVC()
    private let frameVC: EditorFrameVC
    
    private let projectID: String
    private let editor: ProjectEditor
    
    private let modelGenerator = EditorModelGenerator()
    private let playbackController = EditorPlaybackController()
    
    private var model: EditorModel = .empty
    private var focusedFrameIndex = 0
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editor = try ProjectEditor(projectID: projectID)
        let projectManifest = editor.currentProjectManifest
        
        frameVC = try EditorFrameVC(
            projectID: projectID,
            projectViewportSize: projectManifest.metadata.viewportSize,
            drawingSize: projectManifest.content.animationLayer.size)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        editor.delegate = self
        playbackController.delegate = self
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
        let projectManifest = editor.currentProjectManifest
        update(projectManifest: projectManifest)
        
        timelineVC.setFocusedFrameIndex(0)
        frameVC.setFocusedFrameIndex(0)
    }
    
    private func update(projectManifest: Project.Manifest) {
        model = modelGenerator.generate(
            from: projectManifest)
        
        focusedFrameIndex = clamp(
            focusedFrameIndex,
            min: 0,
            max: model.frames.count - 1)
        
        timelineVC.setModel(model)
        timelineVC.setFocusedFrameIndex(focusedFrameIndex)
        
        frameVC.setProjectManifest(projectManifest)
        frameVC.setFocusedFrameIndex(focusedFrameIndex)
        
        playbackController.setModel(model)
    }
    
}

// MARK: - View Controller Delegates

extension EditorVC: EditorTimelineVCDelegate {
    
    func onBeginFrameScroll(_ vc: EditorTimelineVC) {
        frameVC.onBeginFrameScroll()
    }
    
    func onEndFrameScroll(_ vc: EditorTimelineVC) {
        frameVC.onEndFrameScroll()
    }
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int
    ) {
        focusedFrameIndex = index
        frameVC.setFocusedFrameIndex(index)
        
        playbackController.stopPlayback()
    }
    
    func onSelectPlayPause(
        _ vc: EditorTimelineVC
    ) {
        if playbackController.isPlaying {
            playbackController.stopPlayback()
        } else {
            playbackController.startPlayback(
                frameIndex: focusedFrameIndex)
        }
    }
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.createEmptyDrawing(
            frameIndex: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.deleteDrawing(at: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: EditorTimelineVC, 
        frameIndex: Int
    ) {
        try? editor.insertSpacing(at: frameIndex)
    }
    
    func onRequestRemoveSpacing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.removeSpacing(at: frameIndex)
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC
    ) {
        frameVC.handleChangeBottomInsetViewFrame()
    }
    
}

extension EditorVC: EditorFrameVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameVC) {
        dismiss(animated: true)
    }
    
    func onSelectUndo(_ vc: EditorFrameVC) {
        try? editor.applyUndo()
    }
    
    func onSelectRedo(_ vc: EditorFrameVC) {
        try? editor.applyRedo()
    }
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        drawingTexture: MTLTexture,
        editContext: Any?
    ) {
        try? editor.editDrawing(
            drawingID: drawingID,
            drawingTexture: drawingTexture,
            editContext: editContext)
    }
    
}

// MARK: - Editor Delegate

extension EditorVC: ProjectEditorDelegate {
    
    func onEditProject(_ editor: ProjectEditor) {
        let projectManifest = editor.currentProjectManifest
        update(projectManifest: projectManifest)
    }
    
}

// MARK: - Playback Controller Delegate

extension EditorVC: EditorPlaybackControllerDelegate {
    
    func onBeginPlayback(
        _ c: EditorPlaybackController
    ) {
        timelineVC.setPlaying(true)
        frameVC.setPlaying(true)
    }
    
    func onUpdatePlayback(
        _ c: EditorPlaybackController,
        frameIndex: Int
    ) {
        timelineVC.setFocusedFrameIndex(frameIndex)
        frameVC.setFocusedFrameIndex(frameIndex)
    }
    
    func onEndPlayback(
        _ c: EditorPlaybackController
    ) {
        timelineVC.setPlaying(false)
        frameVC.setPlaying(false)
    }
    
}
