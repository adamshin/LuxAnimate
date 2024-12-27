//
//  AnimEditorFrameToolbarToolPickerVC.swift
//

import UIKit

class AnimEditorFrameToolbarToolPickerVC: UIViewController {
    
    var delegate:
        AnimEditorFrameToolbarToolPickerView.Delegate?
    {
        get { bodyView.delegate }
        set { bodyView.delegate = newValue }
    }
    
    private let bodyView =
        AnimEditorFrameToolbarToolPickerView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    // MARK: - Interface
    
    func update(
        selectedTool: AnimEditorFrameToolbarVC.Tool?
    ) {
        bodyView.update(selectedTool: selectedTool)
    }
    
}
