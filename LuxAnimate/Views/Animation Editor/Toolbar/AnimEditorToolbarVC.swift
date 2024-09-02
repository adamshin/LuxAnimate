//
//  AnimEditorToolbarVC.swift
//

import UIKit

protocol AnimEditorToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: AnimEditorToolbarVC)
    func onSelectUndo(_ vc: AnimEditorToolbarVC)
    func onSelectRedo(_ vc: AnimEditorToolbarVC)
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC)
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC)
}

class AnimEditorToolbarVC: UIViewController {
    
    weak var delegate: AnimEditorToolbarVCDelegate?
    
    let bodyView = AnimEditorToolbarView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bodyView.backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        bodyView.undoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectUndo(self)
        }
        bodyView.redoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRedo(self)
        }
        
        bodyView.paintButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectPaintTool()
            self.delegate?.onSelectPaintTool(self)
        }
        bodyView.eraseButton.addHandler { [weak self] in
            guard let self else { return }
            self.bodyView.selectEraseTool()
            self.delegate?.onSelectEraseTool(self)
        }
        
        bodyView.selectPaintTool()
    }
    
    func update(
        availableUndoCount: Int,
        availableRedoCount: Int
    ) {
        bodyView.undoButton.isEnabled = availableUndoCount > 0
        bodyView.redoButton.isEnabled = availableRedoCount > 0
    }
    
}
