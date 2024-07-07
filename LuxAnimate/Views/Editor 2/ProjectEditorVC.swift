//
//  ProjectEditorVC.swift
//

import UIKit

class ProjectEditorVC: UIViewController {
    
    private let projectID: String
    
    private let projectEditor: ProjectEditor
    
    private let contentVC = ProjectEditorContentVC()
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        projectEditor = try ProjectEditor(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentVC.delegate = self
        addChild(contentVC, to: view)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Logic
    
}

// MARK: - Delegates

extension ProjectEditorVC: ProjectEditorContentVCDelegate {
    
    func onSelectAddScene(_ vc: ProjectEditorContentVC) {
        
    }
    
    func onSelectRemoveScene(_ vc: ProjectEditorContentVC) {
        
    }
    
    func onSelectUndo(_ vc: ProjectEditorContentVC) {
        
    }
    
    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        
    }
    
}
