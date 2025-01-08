//
//  AnimEditorFrameToolbarVC.swift
//

import UIKit

extension AnimEditorFrameToolbarVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectUndo(_ vc: AnimEditorFrameToolbarVC)
        func onSelectRedo(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectTool(
            _ vc: AnimEditorFrameToolbarVC,
            tool: AnimEditorFrameVC.Tool,
            isAlreadySelected: Bool)
    }
    
}

class AnimEditorFrameToolbarVC: UIViewController {
    
    private let bodyView = AnimEditorFrameToolbarView()
    
    private let toolPickerVC
        = AnimEditorFrameToolbarToolPickerVC()
    
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
        selectedTool: AnimEditorFrameVC.Tool
    ) {
        toolPickerVC.update(selectedTool: selectedTool)
    }
    
    var selectedTool: AnimEditorFrameVC.Tool? {
        toolPickerVC.selectedTool
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
    AnimEditorFrameToolbarToolPickerVC.Delegate {
    
    func onSelectTool(
        _ v: AnimEditorFrameToolbarToolPickerVC,
        tool: AnimEditorFrameVC.Tool,
        isAlreadySelected: Bool
    ) {
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
