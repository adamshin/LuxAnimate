//
//  EditorFrameToolbarVC.swift
//

import UIKit

protocol EditorFrameToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: EditorFrameToolbarVC)
    func onSelectBrushTool(_ vc: EditorFrameToolbarVC)
    func onSelectEraseTool(_ vc: EditorFrameToolbarVC)
    func onSelectUndo(_ vc: EditorFrameToolbarVC)
    func onSelectRedo(_ vc: EditorFrameToolbarVC)
}

class EditorFrameToolbarVC: UIViewController {
    
    weak var delegate: EditorFrameToolbarVCDelegate?
    
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
