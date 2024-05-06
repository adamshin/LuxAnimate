//
//  EditorVC.swift
//

import UIKit
import PhotosUI

// TODO: Frame prerendering and caching
// Coordinate switching frames between timeline/canvas VCs

class EditorVC: UIViewController {
    
    private let drawingVC = EditorDrawingVC()
    private let timelineVC = EditorTimelineVC()
    
    private let projectID: String
    
    private var editor: ProjectEditor?
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        do {
            editor = try ProjectEditor(projectID: projectID)
            editor?.delegate = self
            
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
        
        let model = EditorTimelineModelGenerator
            .generate(from: editor.currentProjectManifest)
        
        timelineVC.setModel(model)
    }
    
}

// MARK: - View Controller Delegates

extension EditorVC: EditorDrawingVCDelegate {
    
    func onSelectBack(_ vc: EditorDrawingVC) {
        dismiss(animated: true)
    }
    
}

extension EditorVC: EditorTimelineVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int
    ) {
        // TODO: Tell drawing view controller to display frame
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC
    ) {
        drawingVC.handleChangeBottomInsetViewFrame()
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
