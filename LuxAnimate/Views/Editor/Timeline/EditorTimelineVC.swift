//
//  EditorTimelineVC.swift
//

import UIKit

private let frameCount = 120
private let framesPerSecond = 24

protocol EditorTimelineVCDelegate: AnyObject {
    
    func onChangeContentAreaSize(
        _ vc: EditorTimelineVC)
    
    func onRequestFocusFrame(
        _ vc: EditorTimelineVC,
        index: Int)
    
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
    
}

class EditorTimelineVC: UIViewController {
    
    weak var delegate: EditorTimelineVCDelegate?
    
    private let collapsibleContentVC = EditorCollapsibleContentVC()
    
    private let toolbarVC = TimelineToolbarVC()
    private let trackVC = TimelineTrackVC()
    
    private var model = EditorTimelineModel(frames: [])
    
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
    
    func setModel(_ model: EditorTimelineModel) {
        self.model = model
        trackVC.setModel(model)
    }
    
    func focusFrame(at index: Int) {
        trackVC.focusFrame(at: index, animated: false)
    }
    
    func setPlaying(_ playing: Bool) {
        toolbarVC.setPlaying(playing)
        trackVC.view.isUserInteractionEnabled = !playing
    }
    
    var focusedFrameIndex: Int {
        trackVC.focusedFrameIndex
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
    
    func onSelectPlayPause(_ vc: TimelineToolbarVC) {
        delegate?.onSelectPlayPause(self)
    }
    
    func onSelectFirstFrame(_ vc: TimelineToolbarVC) {
        delegate?.onRequestFocusFrame(
            self, 
            index: 0)
    }
    
    func onSelectLastFrame(_ vc: TimelineToolbarVC) {
        delegate?.onRequestFocusFrame(
            self, 
            index: frameCount - 1)
    }
    
    func onSelectPreviousFrame(_ vc: TimelineToolbarVC) {
        delegate?.onRequestFocusFrame(
            self,
            index: trackVC.focusedFrameIndex - 1)
    }
    
    func onSelectNextFrame(_ vc: TimelineToolbarVC) {
        delegate?.onRequestFocusFrame(
            self,
            index: trackVC.focusedFrameIndex + 1)
    }
    
    func onSelectToggleExpanded(_ vc: TimelineToolbarVC) {
        collapsibleContentVC.toggleExpanded()
    }
    
}

extension EditorTimelineVC: TimelineTrackVCDelegate {
    
    func onSelectFocusedFrame(_ vc: TimelineTrackVC, index: Int) {
        let frame = model.frames[index]
        
        if frame.hasDrawing {
            showFrameMenu(frameIndex: index)
            
        } else {
            delegate?.onRequestCreateDrawing(self,
                frameIndex: trackVC.focusedFrameIndex)
        }
    }
    
    func onSelectFrame(_ vc: TimelineTrackVC, index: Int) {
        vc.focusFrame(at: index, animated: true)
    }
    
    func onLongPressFrame(_ vc: TimelineTrackVC, index: Int) {
        showFrameMenu(frameIndex: index)
    }
    
    func onChangeFocusedFrame(_ vc: TimelineTrackVC) {
        toolbarVC.updateFrameLabel(
            index: vc.focusedFrameIndex,
            total: frameCount)
        
        delegate?.onChangeFocusedFrame(self,
            index: vc.focusedFrameIndex)
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
