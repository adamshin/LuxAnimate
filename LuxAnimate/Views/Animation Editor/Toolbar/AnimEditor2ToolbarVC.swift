//
//  AnimEditor2ToolbarVC.swift
//

import UIKit

extension AnimEditor2ToolbarVC {
    
    enum Tool {
        case paint
        case erase
    }
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ vc: AnimEditor2ToolbarVC)
        
        func onSelectUndo(_ vc: AnimEditor2ToolbarVC)
        func onSelectRedo(_ vc: AnimEditor2ToolbarVC)
        
        func onSelectTool(
            _ vc: AnimEditor2ToolbarVC,
            tool: Tool,
            isAlreadySelected: Bool)
    }
    
}

class AnimEditor2ToolbarVC: UIViewController {
    
    private let bodyView = AnimEditor2ToolbarView()
    
    private let toolPickerVC
        = AnimEditor2ToolbarToolPickerVC()
    
    weak var delegate: Delegate?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(toolPickerVC,
            to: bodyView.toolPickerContainer)
        
        bodyView.delegate = self
        toolPickerVC.delegate = self
    }
    
    // MARK: - Interface
    
    func update(
        contentViewModel vm: AnimEditorContentViewModel
    ) {
        let undoEnabled = vm.availableUndoCount > 0
        let redoEnabled = vm.availableRedoCount > 0
        
        bodyView.update(
            undoEnabled: undoEnabled,
            redoEnabled: redoEnabled)
    }
    
    func update(
        selectedTool: AnimEditor2ToolbarVC.Tool
    ) {
        toolPickerVC.update(selectedTool: selectedTool)
    }
    
    var selectedTool: AnimEditor2ToolbarVC.Tool? {
        toolPickerVC.selectedTool
    }
    
}

// MARK: - Delegates

extension AnimEditor2ToolbarVC:
    AnimEditor2ToolbarView.Delegate {
    
    func onSelectBack(_ v: AnimEditor2ToolbarView) {
        delegate?.onSelectBack(self)
    }
    func onSelectUndo(_ v: AnimEditor2ToolbarView) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ v: AnimEditor2ToolbarView) {
        delegate?.onSelectRedo(self)
    }
    
}

extension AnimEditor2ToolbarVC:
    AnimEditor2ToolbarToolPickerVC.Delegate {
    
    func onSelectTool(
        _ v: AnimEditor2ToolbarToolPickerVC,
        tool: AnimEditor2ToolbarVC.Tool,
        isAlreadySelected: Bool
    ) {
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
