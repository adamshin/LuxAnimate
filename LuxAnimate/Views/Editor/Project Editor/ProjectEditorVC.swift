//
//  ProjectEditorVC.swift
//

import UIKit
import Color

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    
    private let projectID: String
    
    private let stateManager: ProjectAsyncEditManager
    
    private weak var sceneEditorVC: SceneEditorVC?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        stateManager = try ProjectAsyncEditManager(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        stateManager.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        update(projectState: stateManager.state)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }
    
    // MARK: - Logic
    
    private func update(
        projectState: ProjectEditManager.State
    ) {
        contentVC.update(projectState: projectState)
        sceneEditorVC?.update(projectState: projectState)
    }
    
    // MARK: - Editing
    
    private func addScene() {
        let projectManifest = stateManager
            .state.projectManifest
        
        let edit = try! ProjectEditBuilder.createScene(
            projectManifest: projectManifest,
            name: "Scene",
            frameCount: 100,
            backgroundColor: .white)
            
        stateManager.applyEdit(edit: edit)
    }
    
    private func removeLastScene() {
        let projectManifest = stateManager
            .state.projectManifest
        
        guard let lastSceneRef = projectManifest
            .content.sceneRefs.last
        else { return }
        
        let edit = try! ProjectEditBuilder.deleteScene(
            projectManifest: projectManifest,
            sceneID: lastSceneRef.id)
        
        stateManager.applyEdit(edit: edit)
    }
    
    // MARK: - Navigation
    
    private func showSceneEditor(sceneID: String) {
        do {
            let vc = try SceneEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                projectState: stateManager.state)
            
            vc.delegate = self
            sceneEditorVC = vc
            
            present(vc, animated: true)
            
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
        stateManager.applyUndo()
    }
    
    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        stateManager.applyRedo()
    }
    
    func onSelectScene(
        _ vc: ProjectEditorContentVC,
        sceneID: String
    ) {
        showSceneEditor(sceneID: sceneID)
    }
    
}

extension ProjectEditorVC: SceneEditorVCDelegate {
    
    func onRequestUndo(_ vc: SceneEditorVC) {
        stateManager.applyUndo()
    }
    
    func onRequestRedo(_ vc: SceneEditorVC) {
        stateManager.applyRedo()
    }
    
    func onRequestEdit(
        _ vc: SceneEditorVC,
        edit: ProjectEditManager.Edit
    ) {
        stateManager.applyEdit(edit: edit)
    }
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        
        stateManager.pendingEditAsset(
            assetID: assetID)
    }
    
}

extension ProjectEditorVC: ProjectAsyncEditManager.Delegate {
    
    nonisolated func onUpdateState(
        _ m: ProjectAsyncEditManager,
        state: ProjectEditManager.State
    ) {
        Task { @MainActor in
            update(projectState: state)
        }
    }
    
    nonisolated func onEditError(
        _ m: ProjectAsyncEditManager,
        error: Error
    ) { }
    
}
