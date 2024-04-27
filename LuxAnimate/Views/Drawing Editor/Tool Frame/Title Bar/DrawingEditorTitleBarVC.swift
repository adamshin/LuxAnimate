//
//  DrawingEditorTitleBarVC.swift
//

import UIKit

protocol DrawingEditorTitleBarVCDelegate: AnyObject {
    func onSelectBack(_ vc: DrawingEditorTitleBarVC)
    func onSelectBrush(_ vc: DrawingEditorTitleBarVC)
}

class DrawingEditorTitleBarVC: UIViewController {
    
    weak var delegate: DrawingEditorTitleBarVCDelegate?
    
    let bodyView = DrawingEditorTitleBarView()
    
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
