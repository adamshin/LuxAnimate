//
//  ProjectEditorContentVC.swift
//

import UIKit

protocol ProjectEditorContentVCDelegate: AnyObject {
    
    func onSelectAddScene(_ vc: ProjectEditorContentVC)
    func onSelectRemoveScene(_ vc: ProjectEditorContentVC)
    func onSelectUndo(_ vc: ProjectEditorContentVC)
    func onSelectRedo(_ vc: ProjectEditorContentVC)
    func onSelectBack(_ vc: ProjectEditorContentVC)
    
}

class ProjectEditorContentVC: UIViewController {
    
    weak var delegate: ProjectEditorContentVCDelegate?
    
    private let infoLabel = UILabel()
    
    private let addSceneButton = UIButton(type: .system)
    private let removeSceneButton = UIButton(type: .system)
    private let undoButton = UIButton(type: .system)
    private let redoButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .editorBackground
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Done", for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        view.addSubview(backButton)
        backButton.pinEdges([.top, .trailing], padding: 24)
        backButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectBack(self)
        }
        
        view.addSubview(infoLabel)
        infoLabel.pinEdges([.leading, .top], padding: 24)
        infoLabel.numberOfLines = 0
        
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
        infoText: String,
        removeSceneEnabled: Bool,
        undoEnabled: Bool,
        redoEnabled: Bool
    ) {
        infoLabel.text = infoText
        removeSceneButton.isEnabled = removeSceneEnabled
        undoButton.isEnabled = undoEnabled
        redoButton.isEnabled = redoEnabled
    }
    
}
