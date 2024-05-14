//
//  EditorFrameVC.swift
//

import UIKit
import Metal

protocol EditorFrameVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: EditorFrameVC)
    func onSelectUndo(_ vc: EditorFrameVC)
    func onSelectRedo(_ vc: EditorFrameVC)
    
    func onEditDrawing(
        _ vc: EditorFrameVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize)
    
}

class EditorFrameVC: UIViewController {
    
    weak var delegate: EditorFrameVCDelegate?
    
    private let bodyView = EditorFrameView()
    
    private let frameEditorVC: EditorFrameEditorVC
    private let toolbarVC = EditorFrameToolbarVC()
    private let sidebarVC = EditorFrameSidebarVC()
    
    private let projectID: String
    
    // MARK: - Init
    
    init(
        projectID: String,
        projectViewportSize: PixelSize,
        drawingSize: PixelSize
    ) {
        self.projectID = projectID
        
        frameEditorVC = EditorFrameEditorVC(
            projectID: projectID,
            projectViewportSize: projectViewportSize,
            drawingSize: drawingSize)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() { view = bodyView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameEditorVC.delegate = self
        toolbarVC.delegate = self
        
        addChild(frameEditorVC, to: bodyView.frameEditorContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(sidebarVC, to: bodyView.canvasOverlayContainer)
        
        frameEditorVC.setSafeAreaReferenceView(
            bodyView.canvasOverlayContainer)
    }
    
    // MARK: - Interface
    
    func setProjectManifest(_ projectManifest: Project.Manifest) {
        frameEditorVC.setProjectManifest(projectManifest)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        frameEditorVC.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
        frameEditorVC.setPlaying(playing)
    }
    
    func setOnionSkinOn(_ on: Bool) {
        frameEditorVC.setOnionSkinOn(on)
    }
    
    func onBeginFrameScroll() {
        frameEditorVC.onBeginFrameScroll()
    }
    
    func onEndFrameScroll() {
        frameEditorVC.onEndFrameScroll()
    }
    
    func setBottomInsetView(_ bottomInsetView: UIView) {
        bodyView.setBottomInsetView(bottomInsetView)
    }
    
    func handleChangeBottomInsetViewFrame() {
        view.layoutIfNeeded()
        frameEditorVC.handleChangeSafeAreaReferenceViewFrame()
    }
    
}

// MARK: - Delegates

extension EditorFrameVC: EditorFrameEditorVCDelegate {
    
    func onSelectUndo(_ vc: EditorFrameEditorVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: EditorFrameEditorVC) {
        delegate?.onSelectRedo(self)
    }
    
    func onEditDrawing(
        _ vc: EditorFrameEditorVC,
        drawingID: String,
        imageData: Data,
        imageSize: PixelSize
    ) {
        delegate?.onEditDrawing(
            self,
            drawingID: drawingID,
            imageData: imageData,
            imageSize: imageSize)
    }
    
}

extension EditorFrameVC: EditorFrameToolbarVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectBack(self)
    }
    func onSelectBrush(_ vc: EditorFrameToolbarVC) {
        // TODO: Notify frame editor vc?
//        brushMode = .brush
    }
    func onSelectErase(_ vc: EditorFrameToolbarVC) {
        // TODO: Notify frame editor vc?
//        brushMode = .erase
    }
    func onSelectUndo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectRedo(self)
    }
    func onSetTraceOn(_ vc: EditorFrameToolbarVC, on: Bool) {
        frameEditorVC.setOnionSkinOn(on)
    }
    
}
