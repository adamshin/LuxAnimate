//
//  EditorTimelineVC.swift
//

import UIKit

private let frameCount = 120
private let framesPerSecond = 24

protocol EditorTimelineVCDelegate: AnyObject {
    
    func onBeginFrameScroll(_ vc: EditorTimelineVC)
    func onEndFrameScroll(_ vc: EditorTimelineVC)
    
    func onChangeFocusedFrame(
        _ vc: EditorTimelineVC,
        index: Int)
    
    func onSelectPlayPause(
        _ vc: EditorTimelineVC)
    
    func onRequestCreateDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int)
    
    func onRequestDeleteDrawing(
        _ vc: EditorTimelineVC,
        frameIndex: Int)
    
    func onRequestInsertSpacing(
        _ vc: EditorTimelineVC,
        frameIndex: Int)
    
    func onRequestRemoveSpacing(
        _ vc: EditorTimelineVC,
        frameIndex: Int)
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC)
    
}

class EditorTimelineVC: UIViewController {
    
    weak var delegate: EditorTimelineVCDelegate?
    
    private let collapsibleContentVC = EditorCollapsibleContentVC()
    
    private let toolbarVC = TimelineToolbarVC()
    private let trackVC = TimelineTrackVC()
    
    private var model: EditorModel = .empty
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
        
        collapsibleContentVC.setExpanded(true, animated: false)
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
    
    func setModel(_ model: EditorModel) {
        self.model = model
        
        toolbarVC.setFrameCount(model.frames.count)
        trackVC.setModel(model)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        focusedFrameIndex = index
        toolbarVC.setFocusedFrameIndex(index)
        trackVC.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
        toolbarVC.setPlaying(playing)
        trackVC.setPlaying(playing)
    }
    
    var contentAreaView: UIView {
        collapsibleContentVC.contentAreaView
    }
    
}

// MARK: - Delegates

extension EditorTimelineVC: EditorCollapsibleContentVCDelegate {
    
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

extension EditorTimelineVC: TimelineToolbarVCDelegate {
    
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

extension EditorTimelineVC: TimelineTrackVCDelegate {
    
    func onBeginFrameScroll(_ vc: TimelineTrackVC) {
        delegate?.onBeginFrameScroll(self)
    }
    func onEndFrameScroll(_ vc: TimelineTrackVC) {
        delegate?.onEndFrameScroll(self)
    }
    
    func onChangeFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
        focusedFrameIndex = index
        toolbarVC.setFocusedFrameIndex(index)
        
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
    func onSelectFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
        let frame = model.frames[index]
        if frame.hasDrawing {
            showFrameMenu(frameIndex: index)
        } else {
            delegate?.onRequestCreateDrawing(self,
                frameIndex: index)
        }
    }
    
    func onLongPressFrame(_ vc: TimelineTrackVC, index: Int) {
        showFrameMenu(frameIndex: index)
    }
    
}

extension EditorTimelineVC: EditorMenuViewDelegate {
    
    func onPresent(_ v: EditorMenuView) { }
    
    func onDismiss(_ v: EditorMenuView) {
        trackVC.setOpenMenuFrameIndex(nil)
    }
    
}

extension EditorTimelineVC: EditorTimelineFrameMenuViewDelegate {
    
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
