//
//  EditorFrameTopBarVC.swift
//

import UIKit

protocol EditorFrameTopBarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorFrameTopBarVC)
    func onSelectBrush(_ vc: EditorFrameTopBarVC)
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
        bodyView.brushButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBrush(self)
        }
    }
    
}
