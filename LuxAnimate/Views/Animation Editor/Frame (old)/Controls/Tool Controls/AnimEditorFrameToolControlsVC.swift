//
//  AnimEditorFrameToolControlsVC.swift
//

import UIKit

class AnimEditorFrameToolControlsVC: UIViewController {
    
    private let containerVC =
        PassthroughContainerViewController()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(containerVC, to: view)
    }
    
    func update(
        selectedTool: AnimEditorFrameVC.Tool
    ) {
        switch selectedTool {
        case .paint:
            let vc = AnimEditorBrushToolControlsVC()
            containerVC.show(vc)
            
        case .erase:
            let vc = AnimEditorEraseToolControlsVC()
            containerVC.show(vc)
        }
    }
    
    func showExpandedControls() {
        
    }
    
}
