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
    
    private let timelineModelGenerator = EditorTimelineModelGenerator()
    private let playbackController = EditorPlaybackController()
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editor = try ProjectEditor(projectID: projectID)
        
        let animationLayer = editor
            .currentProjectManifest
            .content.animationLayer
        
        frameVC = EditorFrameVC(
            projectID: projectID,
            animationLayer: animationLayer)
        
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
        updateData(projectManifest: editor.currentProjectManifest)
    }
    
    private func updateData(projectManifest: Project.Manifest) {
        let model = timelineModelGenerator
            .generate(from: projectManifest)
        
        let newFocusedFrameIndex = clamp(
            timelineVC.focusedFrameIndex,
            min: 0,
            max: model.frames.count - 1)
        
        playbackController.setModel(model)
        
        timelineVC.setModel(model)
        timelineVC.setFocusedFrameIndex(newFocusedFrameIndex)
        
        frameVC.showFrame(at: newFocusedFrameIndex, forceReload: true)
    }
    
}

// MARK: - View Controller Delegates

extension EditorVC: EditorTimelineVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int
    ) {
        frameVC.showFrame(at: index)
        
        if playbackController.isPlaying {
            playbackController.stopPlayback()
        }
    }
    
    func onSelectPlayPause(
        _ vc: EditorTimelineVC
    ) {
        if playbackController.isPlaying {
            playbackController.stopPlayback()
        } else {
            playbackController.startPlayback(
                frameIndex: timelineVC.focusedFrameIndex)
        }
    }
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.createEmptyDrawing(
            frameIndex: frameIndex)
        
        frameVC.handleUpdateFrame(at: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.deleteDrawing(
            at: frameIndex)
        
        frameVC.handleUpdateFrame(at: frameIndex)
    }
    
    func onRequestInsertSpacing(
        _ vc: EditorTimelineVC, 
        frameIndex: Int
    ) {
        try? editor.insertSpacing(at: frameIndex)
        frameVC.reloadFrame()
    }
    
    func onRequestRemoveSpacing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor.removeSpacing(at: frameIndex)
        frameVC.reloadFrame()
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
        frameVC.reloadFrame()
    }
    
    func onSelectRedo(_ vc: EditorFrameVC) {
        try? editor.applyRedo()
        frameVC.reloadFrame()
    }
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
        try? editor.editDrawing(
            drawingID: drawingID,
            imageData: imageData,
            imageSize: imageSize)
    }
    
    func currentProjectManifest(
        _ vc: EditorFrameVC
    ) -> Project.Manifest {
        editor.currentProjectManifest
    }
    
}

// MARK: - Editor Delegate

extension EditorVC: ProjectEditorDelegate {
    
    func onEditProject(_ editor: ProjectEditor) {
        updateData(projectManifest: editor.currentProjectManifest)
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
        frameVC.showFrame(at: frameIndex)
    }
    
    func onEndPlayback(
        _ c: EditorPlaybackController
    ) {
        timelineVC.setPlaying(false)
        frameVC.setPlaying(false)
    }
    
}
