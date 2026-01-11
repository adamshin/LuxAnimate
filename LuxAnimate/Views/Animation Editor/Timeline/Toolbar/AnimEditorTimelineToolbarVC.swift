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

    private var frameCount = 0
    private var focusedFrameIndex = 0
    
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
        
        bodyView.frameWidget.previousFrameButton.addTarget(
            self, action: #selector(onSelectPreviousFrame))
        bodyView.frameWidget.nextFrameButton.addTarget(
            self, action: #selector(onSelectNextFrame))
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
    
    @objc private func onSelectPreviousFrame() {
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex - 1)
    }
    
    @objc private func onSelectNextFrame() {
        delegate?.onChangeFocusedFrameIndex(
            self, focusedFrameIndex + 1)
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
    }

    func update(
        focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = focusedFrameIndex
        bodyView.frameWidget.setFocusedFrameIndex(focusedFrameIndex)
    }
    
    func setPlaying(_ playing: Bool) {
//        frameWidgetVC.setPlaying(playing)
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
}
