//
//  DrawingEditorToolFrameVC.swift
//

import UIKit

protocol DrawingEditorToolFrameVCDelegate: AnyObject {
    func onSelectBack(_ vc: DrawingEditorToolFrameVC)
}

class DrawingEditorToolFrameVC: UIViewController {
    
    weak var delegate: DrawingEditorToolFrameVCDelegate?
    
    private let titleBarVC = DrawingEditorTitleBarVC()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleBarContainer = UIView()
        view.addSubview(titleBarContainer)
        titleBarContainer.pinEdges([.horizontal, .top])
        
        addChild(titleBarVC, to: titleBarContainer)
        
        titleBarVC.bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
    }
    
}
