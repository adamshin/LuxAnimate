//
//  AnimEditorBottomBarVC.swift
//

import UIKit

// Temporary, for testing

protocol AnimEditorBottomBarVCDelegate: AnyObject {
    func onSelectPrevFrame(_ vc: AnimEditorBottomBarVC)
    func onSelectNextFrame(_ vc: AnimEditorBottomBarVC)
}

class AnimEditorBottomBarVC: UIViewController {
    
    weak var delegate: AnimEditorBottomBarVCDelegate?
    
    let bodyView = AnimEditorBottomBarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.prevFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPrevFrame(self)
        }
        bodyView.nextFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectNextFrame(self)
        }
    }
    
    func update(
        activeFrameIndex: Int
    ) {
        bodyView.setActiveFrameIndex(activeFrameIndex)
    }
    
}

