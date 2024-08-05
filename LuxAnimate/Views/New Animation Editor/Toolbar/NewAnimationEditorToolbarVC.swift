//
//  NewAnimationEditorToolbarVC.swift
//

import UIKit

protocol NewAnimationEditorToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: NewAnimationEditorToolbarVC)
    func onSelectBrushTool(_ vc: NewAnimationEditorToolbarVC)
    func onSelectEraseTool(_ vc: NewAnimationEditorToolbarVC)
    func onSelectUndo(_ vc: NewAnimationEditorToolbarVC)
    func onSelectRedo(_ vc: NewAnimationEditorToolbarVC)
}

class NewAnimationEditorToolbarVC: UIViewController {
    
    weak var delegate: NewAnimationEditorToolbarVCDelegate?
    
    let bodyView = NewAnimationEditorToolbarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        bodyView.brushButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectBrushTool()
            self.delegate?.onSelectBrushTool(self)
        }
        bodyView.eraseButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectEraseTool()
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
        
        bodyView.selectBrushTool()
    }
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        bodyView.undoButton.isEnabled = availableUndoCount > 0
        bodyView.redoButton.isEnabled = availableRedoCount > 0
    }
    
}

