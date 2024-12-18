//
//  AnimEditorFrameToolbarVC.swift
//

import UIKit

extension AnimEditorFrameToolbarVC {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectPaintTool(_ vc: AnimEditorFrameToolbarVC)
        func onSelectEraseTool(_ vc: AnimEditorFrameToolbarVC)
        
        func onSelectUndo(_ vc: AnimEditorFrameToolbarVC)
        func onSelectRedo(_ vc: AnimEditorFrameToolbarVC)
    }
    
}

class AnimEditorFrameToolbarVC: UIViewController {
    
    weak var delegate: Delegate?
    
    private let bodyView = AnimEditorFrameToolbarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        
        bodyView.paintButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPaintTool(self)
        }
        bodyView.eraseButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectEraseTool(self)
        }
        
        bodyView.undoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectUndo(self)
        }
        bodyView.redoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRedo(self)
        }
    }
    
    var remainderContentView: UIView {
        bodyView.remainderContentView
    }
    
    func update(
        projectState: ProjectEditManager.State
    ) {
        let undoAvailable =
            projectState.availableUndoCount > 0
        let redoAvailable =
            projectState.availableRedoCount > 0
        
        bodyView.undoButton.isEnabled = undoAvailable
        bodyView.redoButton.isEnabled = redoAvailable
    }
    
    func update(selectedTool: AnimEditorState.Tool) {
        switch selectedTool {
        case .paint: bodyView.selectPaintTool()
        case .erase: bodyView.selectEraseTool()
        }
    }
    
}
