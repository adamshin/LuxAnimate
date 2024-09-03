//
//  AnimationEditorTimelineVC.swift
//

import UIKit

private let frameCount = 120
private let framesPerSecond = 24

protocol AnimationTimelineVCDelegate: AnyObject {
    
//    func onBeginFrameScroll(_ vc: AnimationEditorTimelineVC)
//    func onEndFrameScroll(_ vc: AnimationEditorTimelineVC)
    
    func onChangeFocusedFrame(
        _ vc: AnimationEditorTimelineVC,
        index: Int)
    
    func onSelectPlayPause(
        _ vc: AnimationEditorTimelineVC)
    
    func onRequestCreateDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int)
    
    func onRequestDeleteDrawing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int)
    
    func onRequestInsertSpacing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int)
    
    func onRequestRemoveSpacing(
        _ vc: AnimationEditorTimelineVC,
        frameIndex: Int)
    
    func onChangeContentAreaSize(
        _ vc: AnimationEditorTimelineVC)
    
}

class AnimationEditorTimelineVC: UIViewController {
    
    weak var delegate: AnimationTimelineVCDelegate?
    
    private let collapsibleContentVC = EditorCollapsibleContentVC()
    
    private let toolbarVC = TimelineToolbarVC()
    private let trackVC = TimelineTrackVC()
    
    private var model: AnimationTimelineModel = .empty
    private var focusedFrameIndex = 0
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        collapsibleContentVC.delegate = self
        toolbarVC.delegate = self
        trackVC.delegate = self
        
        addChild(collapsibleContentVC, to: view)
        addChild(toolbarVC, to: collapsibleContentVC.barView)
        addChild(trackVC, to: collapsibleContentVC.collapsibleContentView)
    }
    
    // MARK: - Menu
    
    private func showFrameMenu(frameIndex: Int) {
        guard let cell = trackVC.cell(at: frameIndex)
        else { return }
        
        let frame = model.frames[frameIndex]
        
        let contentView = EditorTimelineFrameMenuView(
            frameIndex: frameIndex,
            hasDrawing: frame.hasDrawing)
        
        let menu = EditorMenuView(
            contentView: contentView,
            presentation: .init(
                sourceView: cell,
                sourceViewEffect: .fade))
        
        contentView.delegate = self
        menu.delegate = self
        menu.present(in: self)
        
        trackVC.setOpenMenuFrameIndex(frameIndex)
    }
    
    // MARK: - Interface
    
    func update(
        projectID: String,
        sceneManifest: Scene.Manifest,
        animationLayerContent: Scene.AnimationLayerContent
    ) {
        let model = AnimationTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            animationLayerContent: animationLayerContent)
        
        self.model = model
        
        toolbarVC.setFrameCount(model.frames.count)
        trackVC.setModel(model)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        focusedFrameIndex = index
        toolbarVC.setFocusedFrameIndex(index)
        trackVC.setFocusedFrameIndex(index)
    }
    
    func setExpanded(_ expanded: Bool) {
        collapsibleContentVC.setExpanded(
            expanded, animated: false)
    }
    
    var contentAreaView: UIView {
        collapsibleContentVC.contentAreaView
    }
    
}

// MARK: - Delegates

extension AnimationEditorTimelineVC: EditorCollapsibleContentVCDelegate {
    
    func onSetExpanded(
        _ vc: EditorCollapsibleContentVC,
        _ expanded: Bool
    ) {
        toolbarVC.setExpanded(expanded)
    }
    
    func onChangeContentAreaSize(
        _ vc: EditorCollapsibleContentVC
    ) {
        delegate?.onChangeContentAreaSize(self)
    }
    
}

extension AnimationEditorTimelineVC: TimelineToolbarVCDelegate {
    
    func onChangeFocusedFrame(_ vc: TimelineToolbarVC, index: Int) {
        focusedFrameIndex = index
        trackVC.setFocusedFrameIndex(index)
        
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
    func onSelectPlayPause(_ vc: TimelineToolbarVC) {
        delegate?.onSelectPlayPause(self)
    }
    
    func onSelectToggleExpanded(_ vc: TimelineToolbarVC) {
        collapsibleContentVC.toggleExpanded()
    }
    
}

extension AnimationEditorTimelineVC: TimelineTrackVCDelegate {
    
    func onBeginFrameScroll(_ vc: TimelineTrackVC) {
//        delegate?.onBeginFrameScroll(self)
    }
    func onEndFrameScroll(_ vc: TimelineTrackVC) {
//        delegate?.onEndFrameScroll(self)
    }
    
    func onChangeFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
        focusedFrameIndex = index
        toolbarVC.setFocusedFrameIndex(index)
        
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
    func onSelectFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
        let frame = model.frames[index]
        if !frame.hasDrawing {
            delegate?.onRequestCreateDrawing(self,
                frameIndex: index)
        }
    }
    
    func onLongPressFrame(_ vc: TimelineTrackVC, index: Int) {
        showFrameMenu(frameIndex: index)
    }
    
}

extension AnimationEditorTimelineVC: EditorMenuViewDelegate {
    
    func onPresent(_ v: EditorMenuView) { }
    
    func onDismiss(_ v: EditorMenuView) {
        trackVC.setOpenMenuFrameIndex(nil)
    }
    
}

extension AnimationEditorTimelineVC: EditorTimelineFrameMenuViewDelegate {
    
    func onSelectCreateDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestCreateDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectDeleteDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestDeleteDrawing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectInsertSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestInsertSpacing(self,
            frameIndex: frameIndex)
    }
    
    func onSelectRemoveSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int
    ) {
        delegate?.onRequestRemoveSpacing(self,
            frameIndex: frameIndex)
    }
    
}
