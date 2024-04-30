//
//  TimelineToolbarVC.swift
//

import UIKit

protocol TimelineToolbarVCDelegate: AnyObject {
    func onSelectPlay()
    func onSelectFirstFrame()
    func onSelectLastFrame()
    func onSelectPreviousFrame()
    func onSelectNextFrame()
    func onSelectToggleExpanded()
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
            self?.delegate?.onSelectPlay()
        }
        bodyView.firstFrameButton.addHandler { [weak self] in
            self?.delegate?.onSelectFirstFrame()
        }
        bodyView.lastFrameButton.addHandler { [weak self] in
            self?.delegate?.onSelectLastFrame()
        }
        bodyView.previousFrameButton.addHandler { [weak self] in
            self?.delegate?.onSelectPreviousFrame()
        }
        bodyView.nextFrameButton.addHandler { [weak self] in
            self?.delegate?.onSelectNextFrame()
        }
        bodyView.expandButton.addHandler { [weak self] in
            self?.delegate?.onSelectToggleExpanded()
        }
    }
    
    func setPlayButtonPlaying(_ playing: Bool) {
        bodyView.setPlayButtonPlaying(playing)
    }
    
    func updateFrameLabel(index: Int, total: Int) {
        bodyView.updateFrameLabel(index: index, total: total)
    }
    
    func setExpanded(_ expanded: Bool) {
        bodyView.setExpanded(expanded)
    }
    
}
