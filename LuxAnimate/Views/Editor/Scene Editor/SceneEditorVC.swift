//
//  SceneEditorVC.swift
//

import UIKit

@MainActor
protocol SceneEditorVCDelegate: AnyObject {
    
    func onRequestUndo(_ vc: SceneEditorVC)
    func onRequestRedo(_ vc: SceneEditorVC)
    
    func onRequestEdit(
        _ vc: SceneEditorVC,
        edit: ProjectEditManager.Edit,
        editContext: Sendable?)
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset?
    
}

struct SceneEditorVCEditContext {
    var sender: SceneEditorVC
    var sceneManifest: Scene.Manifest
    var wrappedEditContext: Sendable?
}

class SceneEditorVC: UIViewController {
    
    weak var delegate: SceneEditorVCDelegate?
    
    private let contentVC = SceneEditorContentVC()
    
    private let projectID: String
    private let sceneID: String
    
    private var projectState: ProjectEditManager.State
    private var sceneRef: Project.SceneRef
    private var sceneManifest: Scene.Manifest
    
    private weak var animEditorVC: AnimEditorVC2?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        projectState: ProjectEditManager.State
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.projectState = projectState
        
        let projectManifest = projectState
            .projectManifest
        
        let sceneRef = try Self.sceneRefFromProject(
            projectManifest: projectManifest,
            sceneID: sceneID)
        
        let sceneManifest = try SceneEditorSceneManifestLoader
            .load(
                projectManifest: projectManifest,
                sceneID: sceneID)
        
        self.sceneRef = sceneRef
        self.sceneManifest = sceneManifest
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        updateState(
            projectState: projectState,
            sceneRef: sceneRef,
            sceneManifest: sceneManifest,
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
    
    private func updateState(
        projectState: ProjectEditManager.State,
        editContext: Sendable?
    ) {
        let projectManifest = projectState
            .projectManifest
        
        guard let sceneRef = try? Self.sceneRefFromProject(
            projectManifest: projectManifest,
            sceneID: sceneID)
        else {
            dismiss()
            return
        }
        
        if let context = editContext as? SceneEditorVCEditContext,
            context.sender == self
        {
            updateState(
                projectState: projectState,
                sceneRef: sceneRef,
                sceneManifest: context.sceneManifest,
                editContext: context.wrappedEditContext)
            
        } else {
            do {
                let sceneManifest = try SceneEditorSceneManifestLoader
                    .load(
                        projectManifest: projectManifest,
                        sceneID: sceneID)
                
                updateState(
                    projectState: projectState,
                    sceneRef: sceneRef,
                    sceneManifest: sceneManifest,
                    editContext: nil)
                
            } catch { }
        }
    }
    
    private func updateState(
        projectState: ProjectEditManager.State,
        sceneRef: Project.SceneRef,
        sceneManifest: Scene.Manifest,
        editContext: Sendable?
    ) {
        self.projectState = projectState
        self.sceneRef = sceneRef
        self.sceneManifest = sceneManifest
        
        contentVC.update(
            projectState: projectState,
            sceneRef: sceneRef,
            sceneManifest: sceneManifest)
        
        animEditorVC?.update(
            projectState: projectState,
            sceneManifest: sceneManifest,
            editContext: editContext)
    }
    
    // MARK: - Editing
    
    private func addLayer() {
        let projectManifest = projectState
            .projectManifest
        
        let sceneEdit = SceneEditBuilder.createAnimationLayer(
            sceneManifest: sceneManifest,
            drawingCount: 1)
        
        let edit = try! ProjectEditBuilder.applySceneEdit(
            projectManifest: projectManifest,
            sceneEdit: sceneEdit)
        
        let editContext = SceneEditorVCEditContext(
            sender: self,
            sceneManifest: sceneEdit.sceneManifest)
        
        delegate?.onRequestEdit(self,
            edit: edit,
            editContext: editContext)
    }
    
    private func removeLastLayer() {
        guard let lastLayer = sceneManifest.layers.last
        else { return }
        
        let projectManifest = projectState
            .projectManifest
        
        let sceneEdit = try! SceneEditBuilder.deleteLayer(
            sceneManifest: sceneManifest,
            layerID: lastLayer.id)
        
        let edit = try! ProjectEditBuilder.applySceneEdit(
            projectManifest: projectManifest,
            sceneEdit: sceneEdit)
        
        let editContext = SceneEditorVCEditContext(
            sender: self,
            sceneManifest: sceneEdit.sceneManifest)
        
        delegate?.onRequestEdit(self,
            edit: edit,
            editContext: editContext)
    }
    
    // MARK: - Navigation
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    private func showLayerEditor(layerID: String) {
        guard let layer = sceneManifest.layers
            .first(where: { $0.id == layerID })
        else { return }
        
        switch layer.content {
        case .animation:
            showAnimationLayerEditor(layerID: layerID)
        }
    }
    
    private func showAnimationLayerEditor(layerID: String) {
        do {
            let vc = try AnimEditorVC2(
                projectID: projectID,
                sceneID: sceneID,
                layerID: layerID,
                projectState: projectState,
                sceneManifest: sceneManifest,
                focusedFrameIndex: 0)
            
            vc.delegate = self
            
            present(vc, animated: true)
            animEditorVC = vc
            
        } catch { }
    }
    
    // MARK: - Interface
    
    func update(
        projectState: ProjectEditManager.State,
        editContext: Sendable?
    ) {
        updateState(
            projectState: projectState,
            editContext: editContext)
    }
    
}

// MARK: - Scene Ref

extension SceneEditorVC {
    
    enum SceneRefError: Error {
        case invalidSceneID
    }
    
    static func sceneRefFromProject(
        projectManifest: Project.Manifest,
        sceneID: String
    ) throws -> Project.SceneRef {
        
        guard let sceneRef = projectManifest
            .content.sceneRefs
            .first(where: { $0.id == sceneID })
        else {
            throw SceneRefError.invalidSceneID
        }
        return sceneRef
    }
    
}

// MARK: - Delegates

extension SceneEditorVC: SceneEditorContentVCDelegate {
    
    func onSelectBack(_ vc: SceneEditorContentVC) {
        dismiss(animated: true)
    }
    
    func onSelectAddLayer(
        _ vc: SceneEditorContentVC
    ) { 
        addLayer()
    }
    
    func onSelectRemoveLayer(_ vc: SceneEditorContentVC) {
        removeLastLayer()
    }
    
    func onSelectUndo(_ vc: SceneEditorContentVC) { 
        delegate?.onRequestUndo(self)
    }
    
    func onSelectRedo(_ vc: SceneEditorContentVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onSelectLayer(
        _ vc: SceneEditorContentVC,
        layerID: String
    ) {
        showLayerEditor(layerID: layerID)
    }
    
}

extension SceneEditorVC: AnimEditorVC2Delegate {
    
    func onRequestUndo(_ vc: AnimEditorVC2) {
        delegate?.onRequestUndo(self)
    }
    func onRequestRedo(_ vc: AnimEditorVC2) {
        delegate?.onRequestRedo(self)
    }
    
    func onRequestSceneEdit(
        _ vc: AnimEditorVC2,
        sceneEdit: ProjectEditBuilder.SceneEdit,
        editContext: Sendable?
    ) {
        do {
            let projectManifest = projectState
                .projectManifest
            
            let edit = try ProjectEditBuilder.applySceneEdit(
                projectManifest: projectManifest,
                sceneEdit: sceneEdit)
            
            let newEditContext = SceneEditorVCEditContext(
                sender: self,
                sceneManifest: sceneEdit.sceneManifest,
                wrappedEditContext: editContext)
            
            delegate?.onRequestEdit(self,
                edit: edit,
                editContext: newEditContext)
            
        } catch { }
    }
    
    func pendingEditAsset(
        _ vc: AnimEditorVC2,
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        delegate?.pendingEditAsset(assetID: assetID)
    }
    
}
