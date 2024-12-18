//
//  AnimEditorFrameControlsVC.swift
//

import UIKit

class AnimEditorFrameControlsVC: UIViewController {
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = AnimEditorBrushToolControlsVC()
        addChild(vc, to: view)
    }
    
}
