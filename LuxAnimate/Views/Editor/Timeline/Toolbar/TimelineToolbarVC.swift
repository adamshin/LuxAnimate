//
//  TimelineToolbarVC.swift
//

import UIKit

protocol TimelineToolbarVCDelegate: AnyObject {
    func onSelectPlayPause(_ vc: TimelineToolbarVC)
    func onSelectFirstFrame(_ vc: TimelineToolbarVC)
    func onSelectLastFrame(_ vc: TimelineToolbarVC)
    func onSelectPreviousFrame(_ vc: TimelineToolbarVC)
    func onSelectNextFrame(_ vc: TimelineToolbarVC)
    func onSelectToggleExpanded(_ vc: TimelineToolbarVC)
}

class TimelineToolbarVC: UIViewController {
    
    weak var delegate: TimelineToolbarVCDelegate?
    
    private let bodyView = TimelineToolbarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.playButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPlayPause(self)
        }
        bodyView.firstFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectFirstFrame(self)
        }
        bodyView.lastFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectLastFrame(self)
        }
        bodyView.expandButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectToggleExpanded(self)
        }
        
        bodyView.frameWidget.delegate = self
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        bodyView.frameWidget.setFocusedFrameIndex(index)
    }
    
    func setPlaying(_ playing: Bool) {
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
}

extension TimelineToolbarVC: TimelineToolbarFrameWidgetDelegate {
    
    func onSelectPreviousFrame(
        _ v: TimelineToolbarFrameWidget
    ) {
        delegate?.onSelectPreviousFrame(self)
    }
    
    func onSelectNextFrame(
        _ v: TimelineToolbarFrameWidget
    ) {
        delegate?.onSelectNextFrame(self)
    }
    
}
