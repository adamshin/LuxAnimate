//
//  AnimEditorTimelineToolbarVC.swift
//

import UIKit

extension AnimEditorTimelineToolbarVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeFocusedFrameIndex(
            _ vc: AnimEditorTimelineToolbarVC,
            _ focusedFrameIndex: Int)
        
        func onSelectPlayPause(
            _ vc: AnimEditorTimelineToolbarVC)
        
        func onSelectToggleExpanded(
            _ vc: AnimEditorTimelineToolbarVC)
        
    }
    
}

class AnimEditorTimelineToolbarVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let bodyView = TimelineToolbarView()
    
    private let frameWidgetVC =
        AnimEditorTimelineToolbarFrameWidgetVC()
    
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
        let frameIndex = 0
        frameWidgetVC.setFocusedFrameIndex(frameIndex)
        
        delegate?.onChangeFocusedFrameIndex(
            self, frameIndex)
    }
    
    @objc private func onSelectLastFrame() {
        let frameIndex = frameCount - 1
        frameWidgetVC.setFocusedFrameIndex(frameIndex)
        
        delegate?.onChangeFocusedFrameIndex(
            self, frameIndex)
    }
    
    @objc private func onSelectPlayPause() {
        delegate?.onSelectPlayPause(self)
    }
    
    @objc private func onSelectExpand() {
        delegate?.onSelectToggleExpanded(self)
    }
    
    // MARK: - Interface
    
    func setPlaying(_ playing: Bool) {
//        frameWidgetVC.setPlaying(playing)
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
    
}

extension AnimEditorTimelineToolbarVC:
    AnimEditorTimelineToolbarFrameWidgetVC.Delegate {
    
    func onChangeFocusedFrameIndex(
        _ vc: AnimEditorTimelineToolbarFrameWidgetVC,
        _ focusedFrameIndex: Int
    ) {
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex)
    }
    
}
