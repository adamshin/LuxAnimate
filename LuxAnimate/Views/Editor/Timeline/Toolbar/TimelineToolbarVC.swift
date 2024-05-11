//
//  TimelineToolbarVC.swift
//

import UIKit

protocol TimelineToolbarVCDelegate: AnyObject {
    
    func onBeginFrameScroll(_ vc: TimelineToolbarVC)
    func onEndFrameScroll(_ vc: TimelineToolbarVC)
    
    func onChangeFocusedFrame(_ vc: TimelineToolbarVC, index: Int)
    
    func onSelectPlayPause(_ vc: TimelineToolbarVC)
    func onSelectToggleExpanded(_ vc: TimelineToolbarVC)
    
}

class TimelineToolbarVC: UIViewController {
    
    weak var delegate: TimelineToolbarVCDelegate?
    
    private let bodyView = TimelineToolbarView()
    private let frameWidgetVC = TimelineToolbarFrameWidgetVC()
    
    private var frameCount = 0
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.firstFrameButton.addTarget(
            self, action: #selector(onSelectFirstFrame))
        bodyView.lastFrameButton.addTarget(
            self, action: #selector(onSelectLastFrame))
        bodyView.playButton.addTarget(
            self, action: #selector(onSelectPlayPause))
        bodyView.expandButton.addTarget(
            self, action: #selector(onSelectExpand))
        
        frameWidgetVC.delegate = self
        addChild(frameWidgetVC, to: bodyView.frameWidgetContainer)
    }
    
    // MARK: - Handlers
    
    @objc private func onSelectFirstFrame() {
        let index = 0
        frameWidgetVC.setFocusedFrameIndex(index)
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
    @objc private func onSelectLastFrame() {
        let index = frameCount - 1
        frameWidgetVC.setFocusedFrameIndex(index)
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
    @objc private func onSelectPlayPause() {
        delegate?.onSelectPlayPause(self)
    }
    
    @objc private func onSelectExpand() {
        delegate?.onSelectToggleExpanded(self)
    }
    
    // MARK: - Interface
    
    func setPlaying(_ playing: Bool) {
        frameWidgetVC.setPlaying(playing)
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
    func setFrameCount(_ frameCount: Int) {
        self.frameCount = frameCount
        frameWidgetVC.setFrameCount(frameCount)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        frameWidgetVC.setFocusedFrameIndex(index)
    }
    
    func setFrameScrollEnabled(_ enabled: Bool) {
        frameWidgetVC.view.isUserInteractionEnabled = enabled
    }
    
}

extension TimelineToolbarVC: TimelineToolbarFrameWidgetVCDelegate {
    
    func onBeginFrameScroll(_ vc: TimelineToolbarFrameWidgetVC) {
        // TODO: Disable interaction with other buttons
        delegate?.onBeginFrameScroll(self)
    }
    
    func onEndFrameScroll(_ vc: TimelineToolbarFrameWidgetVC) {
        delegate?.onEndFrameScroll(self)
    }
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetVC,
        index: Int
    ) {
        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
}
