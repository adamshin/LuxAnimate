//
//  ProjectEditorContentVC.swift
//

import UIKit

protocol ProjectEditorContentVCDelegate: AnyObject {
    
    func onSelectAddScene(_ vc: ProjectEditorContentVC)
    func onSelectRemoveScene(_ vc: ProjectEditorContentVC)
    func onSelectUndo(_ vc: ProjectEditorContentVC)
    func onSelectRedo(_ vc: ProjectEditorContentVC)
    
}

class ProjectEditorContentVC: UIViewController {
    
    weak var delegate: ProjectEditorContentVCDelegate?
    
    private let addSceneButton = UIButton(type: .system)
    private let removeSceneButton = UIButton(type: .system)
    private let undoButton = UIButton(type: .system)
    private let redoButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 40
        
        view.addSubview(buttonStack)
        buttonStack.pinEdges(.bottom, padding: 40)
        buttonStack.pin(.centerX)
        buttonStack.pinHeight(to: 48)
        
        addSceneButton.setTitle("Add Scene", for: .normal)
        removeSceneButton.setTitle("Remove Scene", for: .normal)
        undoButton.setTitle("Undo", for: .normal)
        redoButton.setTitle("Redo", for: .normal)
        
        buttonStack.addArrangedSubview(addSceneButton)
        buttonStack.addArrangedSubview(removeSceneButton)
        buttonStack.addArrangedSubview(undoButton)
        buttonStack.addArrangedSubview(redoButton)
        
        addSceneButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectAddScene(self)
        }
        removeSceneButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRemoveScene(self)
        }
        undoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectUndo(self)
        }
        redoButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectRedo(self)
        }
    }
    
    func update(
        removeSceneEnabled: Bool,
        undoEnabled: Bool,
        redoEnabled: Bool
    ) {
        removeSceneButton.isEnabled = removeSceneEnabled
        undoButton.isEnabled = undoEnabled
        redoButton.isEnabled = redoEnabled
    }
    
}
