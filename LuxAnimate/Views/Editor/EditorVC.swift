//
//  EditorVC.swift
//

import UIKit

class EditorVC: UIViewController {
    
    private let contentVC = EditorContentVC()
    
    private let projectID: String
    private let projectEditor: ProjectEditor
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        projectEditor = try! ProjectEditor(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }
    
    // MARK: - UI
    
    private func updateUI() {
        let projectName = projectEditor
            .currentProjectManifest
            .name
        
        let drawings = projectEditor
            .currentProjectManifest
            .timeline
            .drawings
        .map { 
            EditorContentVC.Drawing(id: $0.id)
        }
        
        contentVC.update(projectName: projectName)
        contentVC.update(drawings: drawings)
    }
    
}

// MARK: - Delegates

extension EditorVC: EditorContentVCDelegate {
    
    func onSelectBack() {
        dismiss(animated: true)
    }
    
    func onSelectCreateDrawing() {
        // TODO
    }
    
    func onSelectDrawing(id: String) {
        // TODO
    }
    
}
