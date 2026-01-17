//
//  AnimEditorToolbarToolPickerVC.swift
//

import UIKit

extension AnimEditorToolbarToolPickerVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectTool(
            _ vc: AnimEditorToolbarToolPickerVC,
            tool: AnimEditorToolbarVC.Tool,
            isAlreadySelected: Bool)
        
    }
    
}

class AnimEditorToolbarToolPickerVC: UIViewController {
    
    private var selectedTool: AnimEditorToolbarVC.Tool?
    
    weak var delegate: Delegate?
    
    private let bodyView =
        AnimEditorToolbarToolPickerView()
    
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
        selectedTool: AnimEditorToolbarVC.Tool?
    ) {
        self.selectedTool = selectedTool
        bodyView.update(selectedTool: selectedTool)
    }
    
}

// MARK: - Delegates

extension AnimEditorToolbarToolPickerVC:
    AnimEditorToolbarToolPickerView.Delegate {
    
    func onSelectTool(
        _ v: AnimEditorToolbarToolPickerView,
        tool: AnimEditorToolbarVC.Tool
    ) {
        let isAlreadySelected = selectedTool == tool
        selectedTool = tool
        
        bodyView.update(selectedTool: tool)
        
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
