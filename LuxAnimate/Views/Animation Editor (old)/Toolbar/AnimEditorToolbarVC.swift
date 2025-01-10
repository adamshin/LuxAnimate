//
//  AnimEditorToolbarVC.swift
//

import UIKit

@MainActor
protocol AnimEditorToolbarVCDelegate: AnyObject {
    func onSelectBack(_ vc: AnimEditorToolbarVC)
    
    func onSelectPaintTool(_ vc: AnimEditorToolbarVC)
    func onSelectEraseTool(_ vc: AnimEditorToolbarVC)
    
    func onSelectToggleOnionSkin(_ vc: AnimEditorToolbarVC)
    
    func onSelectUndo(_ vc: AnimEditorToolbarVC)
    func onSelectRedo(_ vc: AnimEditorToolbarVC)
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
        
        bodyView.paintButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPaintTool(self)
        }
        bodyView.eraseButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectEraseTool(self)
        }
        
        bodyView.onionSkinButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectToggleOnionSkin(self)
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
    
    func update(projectState: ProjectEditManager.State) {
        let undoEnabled =
            projectState.availableUndoCount > 0
        let redoEnabled =
            projectState.availableRedoCount > 0
        
        bodyView.undoButton.isEnabled = undoEnabled
        bodyView.redoButton.isEnabled = redoEnabled
    }
    
    func update(selectedTool: AnimEditorState.Tool) {
        switch selectedTool {
        case .paint: bodyView.selectPaintTool()
        case .erase: bodyView.selectEraseTool()
        }
    }
    
    func update(onionSkinOn: Bool) {
        bodyView.setOnionSkinOn(onionSkinOn)
    }
    
}
