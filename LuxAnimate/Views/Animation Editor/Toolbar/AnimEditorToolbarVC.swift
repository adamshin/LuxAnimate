//
//  AnimEditorToolbarVC.swift
//

import UIKit

extension AnimEditorToolbarVC {
    
    enum Tool {
        case paint
        case erase
    }
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ vc: AnimEditorToolbarVC)
        
        func onSelectUndo(_ vc: AnimEditorToolbarVC)
        func onSelectRedo(_ vc: AnimEditorToolbarVC)
        
        func onSelectOnionSkin(_ vc: AnimEditorToolbarVC)
        
        func onSelectTool(
            _ vc: AnimEditorToolbarVC,
            tool: Tool,
            isAlreadySelected: Bool)
    }
    
}

class AnimEditorToolbarVC: UIViewController {
    
    private let bodyView = AnimEditorToolbarView()
    
    private let toolPickerVC
        = AnimEditorToolbarToolPickerVC()
    
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
        model: AnimEditorModel
    ) {
        let undoEnabled = model.availableUndoCount > 0
        let redoEnabled = model.availableRedoCount > 0
        
        bodyView.update(
            undoEnabled: undoEnabled,
            redoEnabled: redoEnabled)
    }
    
    func update(isOnionSkinOn: Bool) {
        bodyView.update(isOnionSkinOn: isOnionSkinOn)
    }
    
    func update(
        selectedTool: AnimEditorToolbarVC.Tool
    ) {
        toolPickerVC.update(selectedTool: selectedTool)
    }
    
}

// MARK: - Delegates

extension AnimEditorToolbarVC:
    AnimEditorToolbarView.Delegate {
    
    func onSelectBack(_ v: AnimEditorToolbarView) {
        delegate?.onSelectBack(self)
    }
    func onSelectOnionSkin(_ v: AnimEditorToolbarView) {
        delegate?.onSelectOnionSkin(self)
    }
    func onSelectUndo(_ v: AnimEditorToolbarView) {
        delegate?.onSelectUndo(self)
    }
    func onSelectRedo(_ v: AnimEditorToolbarView) {
        delegate?.onSelectRedo(self)
    }
    
}

extension AnimEditorToolbarVC:
    AnimEditorToolbarToolPickerVC.Delegate {
    
    func onSelectTool(
        _ v: AnimEditorToolbarToolPickerVC,
        tool: AnimEditorToolbarVC.Tool,
        isAlreadySelected: Bool
    ) {
        delegate?.onSelectTool(self,
            tool: tool,
            isAlreadySelected: isAlreadySelected)
    }
    
}
