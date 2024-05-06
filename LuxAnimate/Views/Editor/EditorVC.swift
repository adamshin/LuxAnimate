//
//  EditorVC.swift
//

import UIKit
import PhotosUI

// TODO: Frame prerendering and caching
// Coordinate switching frames between timeline/canvas VCs

class EditorVC: UIViewController {
    
    private var drawingVC: EditorDrawingVC?
    private let timelineVC = EditorTimelineVC()
    
    private let projectID: String
    
    private var editor: ProjectEditor?
    
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
            
            drawingVC = EditorDrawingVC(
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
        guard let drawingVC else { return }
        
        drawingVC.delegate = self
        timelineVC.delegate = self
        
        addChild(drawingVC, to: view)
        addChild(timelineVC, to: view)
        
        drawingVC.setBottomInsetView(
            timelineVC.contentAreaView)
    }
    
    // MARK: - Data
    
    private func setInitialData() {
        guard let editor else { return }
        
        let projectManifest = editor.currentProjectManifest
        
        let model = EditorTimelineModelGenerator
            .generate(from: projectManifest)
        
        timelineVC.setModel(model)
    }
    
}

// MARK: - View Controller Delegates

extension EditorVC: EditorDrawingVCDelegate {
    
    func onSelectBack(_ vc: EditorDrawingVC) {
        dismiss(animated: true)
    }
    
    func onEditDrawing(
        _ vc: EditorDrawingVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
        try? editor?.editDrawing(
            drawingID: drawingID,
            imageData: imageData,
            imageSize: imageSize)
    }
    
}

extension EditorVC: EditorTimelineVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int
    ) {
        guard let editor else { return }
        
        let projectManifest = editor.currentProjectManifest
        let animationLayer = projectManifest.content.animationLayer
        
        guard let drawing = animationLayer.drawings
            .first(where: { $0.frameIndex == index })
        else { return }
        
        drawingVC?.showDrawing(drawing)
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC
    ) {
        drawingVC?.handleChangeBottomInsetViewFrame()
    }
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor?.createEmptyDrawing(
            frameIndex: frameIndex)
    }
    
    func onRequestDeleteDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int
    ) {
        try? editor?.deleteDrawing(
            at: frameIndex)
    }
    
}

// MARK: - Editor Delegate

extension EditorVC: ProjectEditorDelegate {
    
    func onEditProject(_ editor: ProjectEditor) {
        let model = EditorTimelineModelGenerator
            .generate(from: editor.currentProjectManifest)
        
        timelineVC.setModel(model)
    }
    
}
