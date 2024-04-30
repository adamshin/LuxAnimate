//
//  EditorTitleBarVC.swift
//

import UIKit

protocol EditorTitleBarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorTitleBarVC)
    func onSelectBrush(_ vc: EditorTitleBarVC)
    func onSelectClear(_ vc: EditorTitleBarVC)
}

class EditorTitleBarVC: UIViewController {
    
    weak var delegate: EditorTitleBarVCDelegate?
    
    let bodyView = EditorTitleBarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        bodyView.clearButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectClear(self)
        }
        bodyView.brushButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBrush(self)
        }
    }
    
}
