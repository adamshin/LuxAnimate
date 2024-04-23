//
//  EditorVC.swift
//

import UIKit

class EditorVC: UIViewController {
    
    private let contentVC = EditorContentVC()
    
    private let projectID: String
    private let editor: ProjectEditor
    
    // MARK: - Init
    
    init(projectID: String) {
        self.projectID = projectID
        
        editor = ProjectEditor(projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        do {
            try editor.startEditSession()
        } catch { }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        editor.endEditSession()
    }
    
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
        guard let projectManifest = editor.projectManifest
        else { return }
        
        let projectName = projectManifest.name
        
        let drawings = projectManifest
            .timeline.drawings
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
