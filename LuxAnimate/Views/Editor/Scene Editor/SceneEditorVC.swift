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
        edit: ProjectEditManager.Edit)
    
    func pendingEditAsset(
        assetID: String
    ) -> ProjectEditManager.NewAsset?
    
}

extension SceneEditorVC {
    
    struct UpdateContext {
        var pendingEditSceneManifest: Scene.Manifest
    }
    
}

class SceneEditorVC: UIViewController {
    
    weak var delegate: SceneEditorVCDelegate?
    
    private let contentVC = SceneEditorContentVC()
    
    private weak var animEditorVC: AnimEditorVC?
    
    private let projectID: String
    private let sceneID: String
    
    private var model: SceneEditorModel
    
    private var updateContext: UpdateContext?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        projectEditorModel: ProjectEditorModel
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        
        model = try Self.model(
            sceneID: sceneID,
            projectEditorModel: projectEditorModel,
            overrideSceneManifest: nil)
        
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
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
        update(model: model)
    }
    
    // MARK: - Update
    
    // TODO: Make this data flow more logically clear?
    // Need to handle initial data as well as updates.
    private func update(model: SceneEditorModel) {
        self.model = model
        
        contentVC.update(model: model)
        animEditorVC?.update(sceneEditorModel: model)
    }
    
    private func withUpdateContext(
        _ updateContext: UpdateContext,
        _ block: () -> Void
    ) {
        self.updateContext = updateContext
        block()
        self.updateContext = nil
    }
    
    // MARK: - Editing
    
    private func addLayer() {
        let sceneEdit =
            SceneEditBuilder.createAnimationLayer(
                sceneManifest: model.sceneManifest,
                drawingCount: 1)
        
        let edit =
            try! ProjectEditBuilder.applySceneEdit(
                projectManifest: model.projectManifest,
                sceneEdit: sceneEdit)
        
        withUpdateContext(.init(
            pendingEditSceneManifest: sceneEdit.sceneManifest))
        {
            delegate?.onRequestEdit(self, edit: edit)
        }
    }
    
    private func removeLastLayer() {
        guard let lastLayer =
            model.sceneManifest.layers.last
        else { return }
        
        let sceneEdit =
            try! SceneEditBuilder.deleteLayer(
                sceneManifest: model.sceneManifest,
                layerID: lastLayer.id)
        
        let edit =
            try! ProjectEditBuilder.applySceneEdit(
                projectManifest: model.projectManifest,
                sceneEdit: sceneEdit)
        
        withUpdateContext(.init(
            pendingEditSceneManifest: sceneEdit.sceneManifest))
        {
            delegate?.onRequestEdit(self, edit: edit)
        }
    }
    
    // MARK: - Navigation
    
    private func dismiss() {
        dismiss(animated: true)
    }
    
    private func showLayerEditor(layerID: String) {
        guard let layer =
            model.sceneManifest.layers
                .first(where: { $0.id == layerID })
        else { return }
        
        switch layer.content {
        case .animation:
            showAnimationLayerEditor(layerID: layerID)
        }
    }
    
    private func showAnimationLayerEditor(layerID: String) {
        do {
            let vc = try AnimEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                layerID: layerID,
                sceneEditorModel: model,
                focusedFrameIndex: 0)
            
            vc.delegate = self
            
            present(vc, animated: true)
            animEditorVC = vc
            
        } catch { }
    }
    
    // MARK: - Interface
    
    func update(projectEditorModel: ProjectEditorModel) {
        guard let model = try? Self.model(
            sceneID: sceneID,
            projectEditorModel: projectEditorModel,
            overrideSceneManifest: updateContext?.pendingEditSceneManifest)
        else {
            dismiss()
            return
        }
        
        update(model: model)
    }
    
}

// MARK: - Model

extension SceneEditorVC {
    
    enum SceneRefError: Error {
        case invalidSceneID
    }
    
    static func model(
        sceneID: String,
        projectEditorModel m: ProjectEditorModel,
        overrideSceneManifest: Scene.Manifest?
    ) throws -> SceneEditorModel {
        
        guard let sceneRef = m.projectManifest
            .content.sceneRefs
            .first(where: { $0.id == sceneID })
        else {
            throw SceneRefError.invalidSceneID
        }
        
        let sceneManifest: Scene.Manifest
        
        if let overrideSceneManifest {
            sceneManifest = overrideSceneManifest
        } else {
            sceneManifest =
                try SceneEditorSceneManifestLoader.load(
                    projectManifest: m.projectManifest,
                    sceneID: sceneID)
        }
        
        return SceneEditorModel(
            projectManifest: m.projectManifest,
            sceneRef: sceneRef,
            sceneManifest: sceneManifest,
            availableUndoCount: m.availableUndoCount,
            availableRedoCount: m.availableRedoCount)
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

extension SceneEditorVC: AnimEditorVC.Delegate {
    
    func onRequestUndo(_ vc: AnimEditorVC) {
        delegate?.onRequestUndo(self)
    }
    func onRequestRedo(_ vc: AnimEditorVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onRequestEdit(
        _ vc: AnimEditorVC,
        layer: Scene.Layer,
        layerContentEdit: AnimationLayerContentEditBuilder.Edit
    ) {
        do {
            let sceneEdit = try AnimationLayerContentEditBuilder
                .applyAnimationLayerContentEdit(
                    sceneManifest: model.sceneManifest,
                    layer: layer,
                    layerContentEdit: layerContentEdit)
            
            let edit = try ProjectEditBuilder.applySceneEdit(
                projectManifest: model.projectManifest,
                sceneEdit: sceneEdit)
            
            delegate?.onRequestEdit(self, edit: edit)
            
        } catch { }
    }
    
    func pendingEditAsset(
        _ vc: AnimEditorVC,
        assetID: String
    ) -> ProjectEditManager.NewAsset? {
        delegate?.pendingEditAsset(assetID: assetID)
    }
    
}
