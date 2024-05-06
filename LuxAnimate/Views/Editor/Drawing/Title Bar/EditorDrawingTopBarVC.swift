//
//  EditorDrawingTopBarVC.swift
//

import UIKit

protocol EditorDrawingTopBarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorDrawingTopBarVC)
    func onSelectBrush(_ vc: EditorDrawingTopBarVC)
}

class EditorDrawingTopBarVC: UIViewController {
    
    weak var delegate: EditorDrawingTopBarVCDelegate?
    
    let bodyView = EditorDrawingTopBarView()
    
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
