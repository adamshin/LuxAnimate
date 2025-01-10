//
//  AnimEditorFrameToolControlsVC.swift
//

import UIKit

protocol AnimEditorToolControlsVC: UIViewController {
    func showExpandedControls()
}

class AnimEditorFrameToolControlsVC: UIViewController {
    
    private let containerVC =
        PassthroughContainerViewController()
    
    private var activeToolControlsVC:
        AnimEditorToolControlsVC?
    
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
            activeToolControlsVC = vc
            containerVC.show(vc)
            
        case .erase:
            let vc = AnimEditorEraseToolControlsVC()
            activeToolControlsVC = vc
            containerVC.show(vc)
        }
    }
    
    func showExpandedControls() {
        activeToolControlsVC?.showExpandedControls()
    }
    
}
