//
//  ProjectEditorVC.swift
//

import UIKit

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    
    private let projectID: String
    
    private let projectEditManager: ProjectAsyncEditManager
    
    private weak var sceneEditorVC: SceneEditorVC?
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        projectEditManager = try ProjectAsyncEditManager(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        projectEditManager.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        update(
            projectEditManagerState: projectEditManager.state,
            editContext: nil)
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
        projectEditManagerState: ProjectEditManager.State,
        editContext: Any?
    ) {
        contentVC.update(
            projectEditManagerState: projectEditManagerState)
        
        sceneEditorVC?.update(
            projectEditManagerState: projectEditManagerState,
            editContext: editContext)
    }
    
    // MARK: - Editing
    
    private func addScene() {
        let projectManifest = projectEditManager
            .state.projectManifest
        
        let config = ProjectEditHelper.NewSceneConfig(
            name: "Scene",
            frameCount: 100,
            backgroundColor: .white)
        
        let edit = try! ProjectEditHelper.createScene(
            projectManifest: projectManifest,
            config: config)
            
        projectEditManager.applyEdit(
            edit: edit,
            editContext: nil)
    }
    
    private func removeLastScene() {
        let projectManifest = projectEditManager
            .state.projectManifest
        
        guard let lastSceneRef = projectManifest
            .content.sceneRefs.last
        else { return }
        
        let edit = try! ProjectEditHelper.deleteScene(
            projectManifest: projectManifest,
            sceneID: lastSceneRef.id)
        
        projectEditManager.applyEdit(
            edit: edit,
            editContext: nil)
    }
    
    // MARK: - Navigation
    
    private func showSceneEditor(sceneID: String) {
        do {
            let vc = try SceneEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                projectEditManagerState: projectEditManager.state)
            
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
        projectEditManager.applyUndo()
    }
    
    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        projectEditManager.applyRedo()
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
        projectEditManager.applyUndo()
    }
    
    func onRequestRedo(_ vc: SceneEditorVC) {
        projectEditManager.applyRedo()
    }
    
    func onRequestEdit(
        _ vc: SceneEditorVC,
        edit: ProjectEditManager.Edit,
        editContext: Any?
    ) {
        projectEditManager.applyEdit(
            edit: edit,
            editContext: editContext)
    }
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        
        projectEditManager.pendingEditAsset(
            assetID: assetID)
    }
    
}

extension ProjectEditorVC: @preconcurrency ProjectAsyncEditManagerDelegate {
    
    func onUpdateState(
        _ m: ProjectAsyncEditManager,
        editContext: Any?
    ) {
        update(
            projectEditManagerState: projectEditManager.state,
            editContext: editContext)
    }
    
    func onError(
        _ m: ProjectAsyncEditManager,
        error: Error
    ) { }
    
}
