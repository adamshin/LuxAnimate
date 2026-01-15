//
//  AnimEditorFrameControlsVC.swift
//

import UIKit

class AnimEditorFrameControlsVC: UIViewController {
    
    private let toolControlsVC =
        AnimEditorFrameToolControlsVC()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(toolControlsVC, to: view)
    }
    
    // MARK: - Interface
    
    func update(
        selectedTool: AnimEditorFrameVC.Tool
    ) {
        toolControlsVC.update(selectedTool: selectedTool)
    }
    
    func showExpandedToolControls() {
        toolControlsVC.showExpandedControls()
    }
    
}
