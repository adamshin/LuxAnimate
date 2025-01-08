//
//  AnimEditorFrameToolbarToolPickerVC.swift
//

import UIKit

extension AnimEditorFrameToolbarToolPickerVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectTool(
            _ vc: AnimEditorFrameToolbarToolPickerVC,
            tool: AnimEditorFrameVC.Tool,
            isAlreadySelected: Bool)
        
    }
    
}

class AnimEditorFrameToolbarToolPickerVC: UIViewController {
    
    private(set) var selectedTool: AnimEditorFrameVC.Tool?
    
    weak var delegate: Delegate?
    
    private let bodyView =
        AnimEditorFrameToolbarToolPickerView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyView.delegate = self
    }
    
    // MARK: - Interface
    
    func update(
        selectedTool: AnimEditorFrameVC.Tool?
    ) {
        self.selectedTool = selectedTool
        bodyView.update(selectedTool: selectedTool)
    }
    
}

// MARK: - Delegates

extension AnimEditorFrameToolbarToolPickerVC:
    AnimEditorFrameToolbarToolPickerView.Delegate {
    
    func onSelectTool(
        _ v: AnimEditorFrameToolbarToolPickerView,
        tool: AnimEditorFrameVC.Tool
    ) {
        let isAlreadySelected = selectedTool == tool
        
        bodyView.update(selectedTool: tool)
        
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
