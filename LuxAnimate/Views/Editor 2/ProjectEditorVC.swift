//
//  ProjectEditorVC.swift
//

import UIKit

class ProjectEditorVC: UIViewController {
    
    private let contentVC = ProjectEditorContentVC()
    
    private let projectID: String
    
    private var projectManifest: Project.Manifest
    
    private let projectEditor: ProjectEditor
    private let sceneEditHelper: SceneEditHelper
    
    // MARK: - Init
    
    init(projectID: String) throws {
        self.projectID = projectID
        
        projectEditor = try ProjectEditor(
            projectID: projectID)
        
        sceneEditHelper = SceneEditHelper()
        
        projectManifest = projectEditor.projectManifest
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        
        sceneEditHelper.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentVC.delegate = self
        addChild(contentVC, to: view)
        
        updateUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - UI
    
    private func updateUI() {
        var infoText = """
            Project ID: \(projectEditor.projectManifest.id)
            Project Name: \(projectEditor.projectManifest.name)
            
            Undo Count: \(projectEditor.availableUndoCount)
            Redo Count: \(projectEditor.availableRedoCount)
            \n
            """
        for sceneRef in projectEditor.projectManifest.content.sceneRefs {
            infoText += "Scene ID: \(sceneRef.id)\n"
        }
        
        let hasScenes = !projectManifest.content.sceneRefs.isEmpty
        
        contentVC.update(
            infoText: infoText,
            removeSceneEnabled: hasScenes,
            undoEnabled: projectEditor.availableUndoCount > 0,
            redoEnabled: projectEditor.availableRedoCount > 0)
    }
    
    // MARK: - Logic
    
    private func addScene() {
        let projectManifest = projectEditor.projectManifest
        
        do {
            try sceneEditHelper.createScene(
                projectManifest: projectManifest,
                name: "Scene",
                frameCount: 100,
                backgroundColor: .white)
            
        } catch { }
    }
    
    private func removeLastScene() {
        let projectManifest = projectEditor.projectManifest
        
        guard let lastSceneRef = projectManifest.content.sceneRefs.last
        else { return }
        
        do {
            try sceneEditHelper.deleteScene(
                projectManifest: projectManifest,
                sceneID: lastSceneRef.id)
            
        } catch { }
    }
    
    private func undo() {
        do {
            try projectEditor.applyUndo()
            updateUI()
            
        } catch { }
    }
    
    private func redo() {
        do {
            try projectEditor.applyRedo()
            updateUI()
            
        } catch { }
    }
    
}

// MARK: - Delegates

extension ProjectEditorVC: ProjectEditorContentVCDelegate {
    
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
    
    func onSelectBack(_ vc: ProjectEditorContentVC) {
        dismiss(animated: true)
    }
    
}

extension ProjectEditorVC: SceneEditHelperDelegate {
    
    func applyEdit(
        _ e: SceneEditHelper,
        newProjectManifest: Project.Manifest,
        newAssets: [ProjectEditor.Asset]
    ) {
        do {
            try projectEditor.applyEdit(
                newProjectManifest: newProjectManifest,
                newAssets: newAssets)
            
            updateUI()
            
        } catch { }
    }
    
}
