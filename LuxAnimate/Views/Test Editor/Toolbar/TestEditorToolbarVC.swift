//
//  TestEditorToolbarVC.swift
//

import UIKit

protocol TestEditorToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: TestEditorToolbarVC)
    func onSelectBrushTool(_ vc: TestEditorToolbarVC)
    func onSelectEraseTool(_ vc: TestEditorToolbarVC)
    func onSelectUndo(_ vc: TestEditorToolbarVC)
    func onSelectRedo(_ vc: TestEditorToolbarVC)
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
