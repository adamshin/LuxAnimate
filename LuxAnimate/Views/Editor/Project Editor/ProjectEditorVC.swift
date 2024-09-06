//
//  ProjectEditorVC.swift
//

import UIKit

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    
    private let projectID: String
    
    private let projectEditManager: ProjectEditManager
    
    private weak var sceneEditorVC: SceneEditorVC?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        projectEditManager = try ProjectEditManager(
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
            projectManifest: projectEditManager.projectManifest,
            undoCount: projectEditManager.availableUndoCount,
            redoCount: projectEditManager.availableRedoCount)
    }
    
    // MARK: - Logic
    
    private func addScene() {
        projectEditManager.createScene(
            name: "Scene",
            frameCount: 100,
            backgroundColor: .white)
            
        // TODO: handle completion?
    }
    
    private func removeLastScene() {
        guard let lastSceneRef = projectEditManager
            .projectManifest.content.sceneRefs.last
        else { return }
        
        do {
            try projectEditManager.deleteScene(
                sceneID: lastSceneRef.id)
            
            // TODO: handle completion?
            
        } catch { }
    }
    
    private func undo() {
        projectEditManager.applyUndo()
        
        // TODO: handle completion?
        
        sceneEditorVC?.update(
            projectManifest: projectEditManager.projectManifest)
    }
    
    private func redo() {
            projectEditManager.applyRedo()
            
        // TODO: handle completion?
            
            sceneEditorVC?.update(
                projectManifest: projectEditManager.projectManifest)
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
        let projectManifest = projectEditManager
            .projectManifest
        
        do {
            let vc = try SceneEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                projectManifest: projectManifest)
            
            vc.delegate = self
            sceneEditorVC = vc
            
            present(vc, animated: true)
            
        } catch { }
    }
    
}

extension ProjectEditorVC: SceneEditorVCDelegate {
    
    func availableUndoCount(_ vc: SceneEditorVC) -> Int {
        projectEditManager.availableUndoCount
    }
    func availableRedoCount(_ vc: SceneEditorVC) -> Int {
        projectEditManager.availableRedoCount
    }
    
    func undo(_ vc: SceneEditorVC) { undo() }
    func redo(_ vc: SceneEditorVC) { redo() }
    
    func applySceneEdit(
        _ vc: SceneEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset]
    ) {
        do {
            try projectEditManager.applySceneEdit(
                sceneID: sceneID,
                newSceneManifest: newSceneManifest,
                newSceneAssets: newSceneAssets)
            
            // Should we be doing this here? or in response
            // to some other action? Depends on how data is
            // going to flow as edits happen.
            DispatchQueue.main.async {
                self.updateUI()
            }
            
        } catch { }
    }
    
}
