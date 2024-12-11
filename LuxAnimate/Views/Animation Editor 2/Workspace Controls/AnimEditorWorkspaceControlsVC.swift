//
//  AnimEditorWorkspaceControlsVC.swift
//

import UIKit

class AnimEditorWorkspaceControlsVC: UIViewController {
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = AnimEditorBrushToolControlsVC()
        addChild(vc, to: view)
    }
    
}
