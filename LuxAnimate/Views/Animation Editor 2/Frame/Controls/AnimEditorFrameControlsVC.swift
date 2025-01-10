//
//  AnimEditorFrameControlsVC.swift
//

import UIKit

// TODO: Switch between displayed tool controls.
// Have tool controls save values in shared store?

class AnimEditorFrameControlsVC: UIViewController {
    
    private let toolControlsContainerVC =
        ContainerViewController()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(toolControlsContainerVC, to: view)
    }
    
    func update(
        selectedTool: AnimEditorFrameVC.Tool
    ) { 
        switch selectedTool {
        case .paint:
            let vc = AnimEditorBrushToolControlsVC()
            toolControlsContainerVC.show(vc)
        case .erase:
            let vc = AnimEditorEraseToolControlsVC()
            toolControlsContainerVC.show(vc)
        }
    }
    
}
