//
//  EditorVC.swift
//

import UIKit
import PhotosUI

// TODO: Frame prerendering and caching

class EditorVC: UIViewController {
    
    private var frameVC: EditorFrameVC?
    private let timelineVC = EditorTimelineVC()
    
    private let projectID: String
    
    private var editor: ProjectEditor?
    
    private let modelGenerator = EditorTimelineModelGenerator()
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        do {
            let editor = try ProjectEditor(projectID: projectID)
            self.editor = editor
            editor.delegate = self
            
            let animationLayer = editor.currentProjectManifest
                .content.animationLayer
            
            frameVC = EditorFrameVC(
                projectID: projectID,
                animationLayer: animationLayer)
            
        } catch { }
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
        guard let frameVC else { return }
        
        frameVC.delegate = self
        timelineVC.delegate = self
        
        addChild(frameVC, to: view)
        addChild(timelineVC, to: view)
        
        frameVC.setBottomInsetView(
            timelineVC.contentAreaView)
    }
    
    // MARK: - Data
    
    private func setInitialData() {
        guard let editor else { return }
        
        let projectManifest = editor.currentProjectManifest
        
        let model = modelGenerator
            .generate(from: projectManifest)
        
        timelineVC.setModel(model)
    }
    
}

// MARK: - View Controller Delegates

extension EditorVC: EditorFrameVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameVC) {
        dismiss(animated: true)
    }
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
        try? editor?.editDrawing(
            drawingID: drawingID,
            imageData: imageData,
            imageSize: imageSize)
    }
    
    func currentProjectManifest(
        _ vc: EditorFrameVC
    ) -> Project.Manifest? {
        
        editor?.currentProjectManifest
    }
    
}

extension EditorVC: EditorTimelineVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int
    ) {
        frameVC?.showFrame(at: index)
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC
    ) {
        frameVC?.handleChangeBottomInsetViewFrame()
    }
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor?.createEmptyDrawing(
            frameIndex: frameIndex)
        
        frameVC?.handleUpdateFrame(at: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor?.deleteDrawing(
            at: frameIndex)
        
        frameVC?.handleUpdateFrame(at: frameIndex)
    }
    
}

// MARK: - Editor Delegate

extension EditorVC: ProjectEditorDelegate {
    
    func onEditProject(_ editor: ProjectEditor) {
        let model = modelGenerator
            .generate(from: editor.currentProjectManifest)
        
        timelineVC.setModel(model)
    }
    
}
