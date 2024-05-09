//
//  EditorFrameToolbarVC.swift
//

import UIKit

protocol EditorFrameToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorFrameToolbarVC)
    func onSelectBrush(_ vc: EditorFrameToolbarVC)
    func onSelectErase(_ vc: EditorFrameToolbarVC)
    func onSelectUndo(_ vc: EditorFrameToolbarVC)
    func onSelectRedo(_ vc: EditorFrameToolbarVC)
}

class EditorFrameToolbarVC: UIViewController {
    
    weak var delegate: EditorFrameToolbarVCDelegate?
    
    let bodyView = EditorFrameToolbarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        bodyView.brushButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectBrush()
            self.delegate?.onSelectBrush(self)
        }
        bodyView.eraseButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectErase()
            self.delegate?.onSelectErase(self)
        }
        bodyView.undoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectUndo(self)
        }
        bodyView.redoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRedo(self)
        }
        
        bodyView.selectBrush()
    }
    
}
