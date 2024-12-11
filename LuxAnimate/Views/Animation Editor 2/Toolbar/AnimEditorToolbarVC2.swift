//
//  AnimEditorToolbarVC2.swift
//

import UIKit

@MainActor
protocol AnimEditorToolbarVC2Delegate: AnyObject {
    func onSelectBack(_ vc: AnimEditorToolbarVC2)
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC2)
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC2)
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC2)
    func onSelectRedo(_ vc: AnimEditorToolbarVC2)
}

class AnimEditorToolbarVC2: UIViewController {
    
    weak var delegate: AnimEditorToolbarVC2Delegate?
    
    private let bodyView = AnimEditorToolbarView2()
    
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
    
    func update(projectState: ProjectEditManager.State) {
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
