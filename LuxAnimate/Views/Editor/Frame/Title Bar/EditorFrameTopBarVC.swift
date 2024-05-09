//
//  EditorFrameTopBarVC.swift
//

import UIKit

protocol EditorFrameTopBarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorFrameTopBarVC)
    func onSelectUndo(_ vc: EditorFrameTopBarVC)
    func onSelectRedo(_ vc: EditorFrameTopBarVC)
}

class EditorFrameTopBarVC: UIViewController {
    
    weak var delegate: EditorFrameTopBarVCDelegate?
    
    let bodyView = EditorFrameTopBarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        bodyView.undoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectUndo(self)
        }
        bodyView.redoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRedo(self)
        }
    }
    
}
