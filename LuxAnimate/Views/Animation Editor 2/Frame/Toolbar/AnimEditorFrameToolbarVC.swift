//
//  AnimEditorFrameToolbarVC.swift
//

import UIKit

extension AnimEditorFrameToolbarVC {
    
    enum Tool {
        case paint
        case erase
    }
    
}

extension AnimEditorFrameToolbarVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectUndo(_ vc: AnimEditorFrameToolbarVC)
        func onSelectRedo(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectTool(
            _ vc: AnimEditorFrameToolbarVC,
            tool: AnimEditorFrameToolbarVC.Tool,
            alreadySelected: Bool)
    }
    
}

class AnimEditorFrameToolbarVC: UIViewController {
    
    private let bodyView = AnimEditorFrameToolbarView()
    
    private let toolPickerVC
        = AnimEditorFrameToolbarToolPickerVC()
    
    weak var delegate: Delegate?
    
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
    
    func update(
        projectState: ProjectEditManager.State
    ) {
        let undoEnabled =
            projectState.availableUndoCount > 0
        let redoEnabled =
            projectState.availableRedoCount > 0
        
        bodyView.update(
            undoEnabled: undoEnabled,
            redoEnabled: redoEnabled)
    }
    
    func update(
        selectedTool: AnimEditorFrameToolbarVC.Tool
    ) {
        toolPickerVC.update(selectedTool: selectedTool)
    }
    
}

// MARK: - Delegates

extension AnimEditorFrameToolbarVC:
    AnimEditorFrameToolbarView.Delegate {
    
    func onSelectBack(_ v: AnimEditorFrameToolbarView) {
        delegate?.onSelectBack(self)
    }
    func onSelectUndo(_ v: AnimEditorFrameToolbarView) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ v: AnimEditorFrameToolbarView) {
        delegate?.onSelectRedo(self)
    }
    
}

extension AnimEditorFrameToolbarVC:
    AnimEditorFrameToolbarToolPickerView.Delegate {
    
    func onSelectTool(
        _ v: AnimEditorFrameToolbarToolPickerView,
        tool: AnimEditorFrameToolbarVC.Tool,
        alreadySelected: Bool
    ) {
        delegate?.onSelectTool(
            self,
            tool: tool,
            alreadySelected: alreadySelected)
    }
    
}
