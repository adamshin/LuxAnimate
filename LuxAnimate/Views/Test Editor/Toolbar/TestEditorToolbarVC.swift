//
//  TestEditorToolbarVC.swift
//

import UIKit

protocol TestEditorToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: TestEditorToolbarVC)
    func onSelectUndo(_ vc: TestEditorToolbarVC)
    func onSelectRedo(_ vc: TestEditorToolbarVC)
    
    func onSelectPaintTool(_ vc: TestEditorToolbarVC)
    func onSelectEraseTool(_ vc: TestEditorToolbarVC)
}

class TestEditorToolbarVC: UIViewController {
    
    weak var delegate: TestEditorToolbarVCDelegate?
    
    let bodyView = EditorFrameToolbarView()
    
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
