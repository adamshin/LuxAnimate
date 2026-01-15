//
//  ProjectEditorVC.swift
//

import UIKit
import Color

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    private weak var sceneEditorVC: SceneEditorVC?
    
    private let projectID: String
    
    private let editManager: ProjectAsyncEditManager
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        editManager = try ProjectAsyncEditManager(
            projectID: projectID)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        editManager.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupInitialState()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentVC.delegate = self
        
        let navController = UINavigationController(
            rootViewController: contentVC)
        addChild(navController, to: view)
    }
    
    private func setupInitialState() {
        let model = modelFromEditManager()
        update(model: model)
    }
    
    // MARK: - Model
    
    private func modelFromEditManager()
    -> ProjectEditorModel {
        
        ProjectEditorModel(
            projectManifest: editManager.projectManifest,
            availableUndoCount: editManager.availableUndoCount,
            availableRedoCount: editManager.availableRedoCount)
    }
    
    // MARK: - Logic
    
    private func update(model: ProjectEditorModel) {
        contentVC.update(model: model)
        sceneEditorVC?.update(projectEditorModel: model)
    }
    
    // MARK: - Editing
    
    private func addScene() {
        let projectManifest = editManager.projectManifest
        
        let edit = try! ProjectEditBuilder.createScene(
            projectManifest: projectManifest,
            name: "Scene",
            frameCount: 100,
            backgroundColor: .white)
            
        editManager.applyEdit(edit: edit)
    }
    
    private func removeLastScene() {
        let projectManifest = editManager.projectManifest
        
        guard let lastSceneRef = projectManifest
            .content.sceneRefs.last
        else { return }
        
        let edit = try! ProjectEditBuilder.deleteScene(
            projectManifest: projectManifest,
            sceneID: lastSceneRef.id)
        
        editManager.applyEdit(edit: edit)
    }
    
    // MARK: - Navigation
    
    private func showSceneEditor(sceneID: String) {
        do {
            let model = modelFromEditManager()
            
            let vc = try SceneEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                projectEditorModel: model)
            
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
        editManager.applyUndo()
    }
    
    func onSelectRedo(_ vc: ProjectEditorContentVC) {
        editManager.applyRedo()
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
        editManager.applyUndo()
    }
    
    func onRequestRedo(_ vc: SceneEditorVC) {
        editManager.applyRedo()
    }
    
    func onRequestEdit(
        _ vc: SceneEditorVC,
        edit: ProjectEditManager.Edit
    ) {
        editManager.applyEdit(edit: edit)
    }
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        
        editManager.pendingEditAsset(
            assetID: assetID)
    }
    
}

extension ProjectEditorVC: ProjectAsyncEditManager.Delegate {
    
    func onUpdateState(
        _ m: ProjectAsyncEditManager
    ) {
        let model = modelFromEditManager()
        update(model: model)
    }
    
    func onEditError(
        _ m: ProjectAsyncEditManager,
        error: Error
    ) { }
    
}
