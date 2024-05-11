//
//  TimelineToolbarVC.swift
//

import UIKit

protocol TimelineToolbarVCDelegate: AnyObject {
    
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
        
//        frameWidgetVC.delegate = self
//        addChild(frameWidgetVC, to: bodyView.frameWidgetContainer)
    }
    
    // MARK: - Handlers
    
    @objc private func onSelectFirstFrame() {
        delegate?.onChangeFocusedFrame(self,
            index: 0)
    }
    
    @objc private func onSelectLastFrame() {
        delegate?.onChangeFocusedFrame(self,
            index: frameCount - 1)
    }
    
    @objc private func onSelectPlayPause() {
        delegate?.onSelectPlayPause(self)
    }
    
    @objc private func onSelectExpand() {
        delegate?.onSelectToggleExpanded(self)
    }
    
    // MARK: - Interface
    
    func setPlaying(_ playing: Bool) {
        bodyView.setPlayButtonPlaying(playing)
//        frameWidgetVC.view.isUserInteractionEnabled = !playing
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
    func setFrameCount(_ frameCount: Int) {
        self.frameCount = frameCount
//        frameWidgetVC.setFrameCount(frameCount)
    }
    
    func setFocusedFrameIndex(_ index: Int) {
//        frameWidgetVC.setFocusedFrameIndex(index)
    }
    
}

extension TimelineToolbarVC: TimelineToolbarFrameWidgetVCDelegate {
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetVC,
        index: Int
    ) {
//        delegate?.onChangeFocusedFrame(self, index: index)
    }
    
}
