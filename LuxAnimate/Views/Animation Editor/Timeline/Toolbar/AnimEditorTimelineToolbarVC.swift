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
        
        func onSelectExpandToggle(
            _ vc: AnimEditorTimelineToolbarVC)
        
    }
    
}

class AnimEditorTimelineToolbarVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let bodyView = AnimEditorTimelineToolbarView()
    
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
        bodyView.expandToggleButton.addTarget(
            self, action: #selector(onSelectExpandToggle))
        
        addChild(frameWidgetVC,
            to: bodyView.frameWidgetContainer)
        frameWidgetVC.delegate = self
    }
    
    // MARK: - Handlers
    
    @objc private func onSelectFirstFrame() {
        delegate?.onChangeFocusedFrameIndex(
            self, 0)
    }
    
    @objc private func onSelectLastFrame() {
        delegate?.onChangeFocusedFrameIndex(
            self, frameCount - 1)
    }
    
    @objc private func onSelectPlayPause() {
        delegate?.onSelectPlayPause(self)
    }
    
    @objc private func onSelectExpandToggle() {
        delegate?.onSelectExpandToggle(self)
    }
    
    // MARK: - Interface
    
    func update(
        timelineViewModel: AnimEditorTimelineViewModel
    ) {
        frameCount = timelineViewModel.frames.count
        
        frameWidgetVC.update(
            timelineViewModel: timelineViewModel)
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        frameWidgetVC.update(
            focusedFrameIndex: focusedFrameIndex)
    }
    
    func setPlaying(_ playing: Bool) {
//        frameWidgetVC.setPlaying(playing)
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
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
