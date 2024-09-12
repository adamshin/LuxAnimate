//
//  AnimationFrameVC.swift
//

import UIKit
import Metal

@MainActor
protocol AnimationFrameVCDelegate: AnyObject {
    
    func onSelectBack(_ vc: AnimationFrameVC)
    func onSelectUndo(_ vc: AnimationFrameVC)
    func onSelectRedo(_ vc: AnimationFrameVC)
    
    func onEditDrawing(
        _ vc: AnimationFrameVC,
        drawingID: String,
        drawingTexture: MTLTexture)
    
}

class AnimationFrameVC: UIViewController {
    
    weak var delegate: AnimationFrameVCDelegate?
    
    private let bodyView = AnimationFrameView()
    
    private let frameEditorVC: AnimationFrameEditorVC
    private let toolbarVC = EditorFrameToolbarVC()
    private let sidebarVC = EditorFrameSidebarVC()
    
    private let projectID: String
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        frameEditorVC = AnimationFrameEditorVC(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() { view = bodyView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameEditorVC.delegate = self
        toolbarVC.delegate = self
        sidebarVC.delegate = self
        
        addChild(frameEditorVC, to: bodyView.frameEditorContainer)
        addChild(toolbarVC, to: bodyView.toolbarContainer)
        addChild(sidebarVC, to: bodyView.canvasOverlayContainer)
        
        frameEditorVC.setSafeAreaReferenceView(
            bodyView.canvasOverlayContainer)
    }
    
    // MARK: - Interface
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        toolbarVC.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
    }
    
    func setProjectManifest(
        _ projectManifest: Project.Manifest,
        editContext: Sendable?
    ) {
//        frameEditorVC.setProjectManifest(
//            projectManifest,
//            editContext: editContext)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
//        frameEditorVC.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
//        frameEditorVC.setPlaying(playing)
    }
    
    func setOnionSkinOn(_ on: Bool) {
//        frameEditorVC.setOnionSkinOn(on)
    }
    
    func onBeginFrameScroll() {
//        frameEditorVC.onBeginFrameScroll()
    }
    
    func onEndFrameScroll() {
//        frameEditorVC.onEndFrameScroll()
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

extension AnimationFrameVC: AnimationFrameEditorVCDelegate {
    
    func onSelectUndo(_ vc: AnimationFrameEditorVC) {
        delegate?.onSelectUndo(self)
    }
    
    func onSelectRedo(_ vc: AnimationFrameEditorVC) {
        delegate?.onSelectRedo(self)
    }
    
}

extension AnimationFrameVC: EditorFrameToolbarVCDelegate {
    
    func onSelectBack(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectBack(self)
    }
    func onSelectBrushTool(_ vc: EditorFrameToolbarVC) {
//        frameEditorVC.selectBrushTool()
    }
    func onSelectEraseTool(_ vc: EditorFrameToolbarVC) {
//        frameEditorVC.selectEraseTool()
    }
    func onSelectUndo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ vc: EditorFrameToolbarVC) {
        delegate?.onSelectRedo(self)
    }
    
}

extension AnimationFrameVC: EditorFrameSidebarVCDelegate {
    
    func onSetBrushScale(
        _ vc: EditorFrameSidebarVC,
        _ brushScale: Double
    ) {
//        frameEditorVC.setBrushScale(brushScale)
    }
    
    func onSetBrushSmoothing(
        _ vc: EditorFrameSidebarVC,
        _ brushSmoothing: Double
    ) {
//        frameEditorVC.setBrushSmoothing(brushSmoothing)
    }
    
}
