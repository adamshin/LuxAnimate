//
//  ProjectEditorVC.swift
//

import UIKit

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    
    private let projectID: String
    
    private let projectEditor: ProjectEditor
    
    private weak var sceneEditorVC: SceneEditorVC?
    
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
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
        
        updateUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Update
    
    private func updateUI() {
        contentVC.update(
            projectManifest: projectEditor.projectManifest,
            undoCount: projectEditor.availableUndoCount,
            redoCount: projectEditor.availableRedoCount)
    }
    
    // MARK: - Logic
    
    private func addScene() {
        do {
            try projectEditor.createScene(
                name: "Scene",
                frameCount: 100,
                backgroundColor: .white)
            
            updateUI()
            
        } catch { }
    }
    
    private func removeLastScene() {
        guard let lastSceneRef = projectEditor
            .projectManifest.content.sceneRefs.last
        else { return }
        
        do {
            try projectEditor.deleteScene(
                sceneID: lastSceneRef.id)
                
            updateUI()
            
        } catch { }
    }
    
    private func undo() {
        do {
            try projectEditor.applyUndo()
            
            updateUI()
            
            sceneEditorVC?.update(
                projectManifest: projectEditor.projectManifest)
            
        } catch { }
    }
    
    private func redo() {
        do {
            try projectEditor.applyRedo()
            
            updateUI()
            
            sceneEditorVC?.update(
                projectManifest: projectEditor.projectManifest)
            
        } catch { }
    }
    
}

// MARK: - Delegates

extension ProjectEditorVC: ProjectEditorContentVCDelegate {
    
    func onSelectBack(_ vc: ProjectEditorContentVC) {
        dismiss(animated: true)
    }
    
    func onSelectAddScene(_ vc: ProjectEditorContentVC) {
        addScene()
    }
    
    func onSelectRemoveScene(_ vc: ProjectEditorContentVC) {
        removeLastScene()
    }
    
    func onSelectUndo(_ vc: ProjectEditorContentVC) {
        undo()
    }
    
    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        redo()
    }
    
    func onSelectScene(
        _ vc: ProjectEditorContentVC,
        sceneID: String
    ) {
        let vc = SceneEditorVC(
            projectID: projectID,
            sceneID: sceneID)
        
        vc.delegate = self
        
        vc.update(
            projectManifest: projectEditor.projectManifest)
        
        present(vc, animated: true)
        sceneEditorVC = vc
    }
    
}

extension ProjectEditorVC: SceneEditorVCDelegate {
    
    func availableUndoCount(_ vc: SceneEditorVC) -> Int {
        projectEditor.availableUndoCount
    }
    func availableRedoCount(_ vc: SceneEditorVC) -> Int {
        projectEditor.availableRedoCount
    }
    
    func onRequestUndo(_ vc: SceneEditorVC) { undo() }
    func onRequestRedo(_ vc: SceneEditorVC) { redo() }
    
    func onRequestApplyEdit(
        _ vc: SceneEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) {
        do {
            try projectEditor.applySceneEdit(
                sceneID: sceneID,
                newSceneManifest: newSceneManifest,
                newSceneAssets: newSceneAssets)
            
            updateUI()
            
        } catch { }
    }
    
}
