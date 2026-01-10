//
//  AnimEditor2ToolbarToolPickerVC.swift
//

import UIKit

extension AnimEditor2ToolbarToolPickerVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectTool(
            _ vc: AnimEditor2ToolbarToolPickerVC,
            tool: AnimEditor2ToolbarVC.Tool,
            isAlreadySelected: Bool)
        
    }
    
}

class AnimEditor2ToolbarToolPickerVC: UIViewController {
    
    private(set) var selectedTool: AnimEditor2ToolbarVC.Tool?
    
    weak var delegate: Delegate?
    
    private let bodyView =
        AnimEditor2ToolbarToolPickerView()
    
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
        selectedTool: AnimEditor2ToolbarVC.Tool?
    ) {
        self.selectedTool = selectedTool
        bodyView.update(selectedTool: selectedTool)
    }
    
}

// MARK: - Delegates

extension AnimEditor2ToolbarToolPickerVC:
    AnimEditor2ToolbarToolPickerView.Delegate {
    
    func onSelectTool(
        _ v: AnimEditor2ToolbarToolPickerView,
        tool: AnimEditor2ToolbarVC.Tool
    ) {
        let isAlreadySelected = selectedTool == tool
        selectedTool = tool
        
        bodyView.update(selectedTool: tool)
        
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
