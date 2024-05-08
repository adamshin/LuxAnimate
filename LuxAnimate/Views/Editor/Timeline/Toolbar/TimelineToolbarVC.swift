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
        bodyView.previousFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPreviousFrame(self)
        }
        bodyView.nextFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectNextFrame(self)
        }
        bodyView.expandButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectToggleExpanded(self)
        }
    }
    
    func setPlaying(_ playing: Bool) {
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func updateFrameLabel(index: Int, total: Int) {
        bodyView.updateFrameLabel(index: index, total: total)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
}
