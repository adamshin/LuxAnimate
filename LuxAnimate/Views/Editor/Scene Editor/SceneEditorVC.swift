//
//  SceneEditorVC.swift
//

import UIKit

protocol SceneEditorVCDelegate: AnyObject {
    
    func availableUndoCount(_ vc: SceneEditorVC) -> Int
    func availableRedoCount(_ vc: SceneEditorVC) -> Int
    
    func undo(_ vc: SceneEditorVC)
    func redo(_ vc: SceneEditorVC)
    
    func applySceneEdit(
        _ vc: SceneEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset])
    
}

class SceneEditorVC: UIViewController {
    
    weak var delegate: SceneEditorVCDelegate?
    
    private let contentVC = SceneEditorContentVC()
    
    private let projectID: String
    private let sceneID: String
    
    private let sceneEditManager: SceneEditManager
    
    private weak var animEditorVC: AnimEditorVC?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        projectManifest: Project.Manifest
    ) throws {
        
        self.projectID = projectID
        self.sceneID = sceneID
        
        sceneEditManager = try SceneEditManager(
            projectID: projectID,
            sceneID: sceneID,
            projectManifest: projectManifest)
        
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
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    // MARK: - Logic
    
    private func handleUpdateData(fromEditor: Bool) {
        guard let delegate else { return }
        
        guard let sceneRef = sceneEditManager
            .projectManifest.content.sceneRefs
            .first(where: { $0.id == sceneID })
        else { return }
        
        let availableUndoCount = delegate.availableUndoCount(self)
        let availableRedoCount = delegate.availableRedoCount(self)
        
        contentVC.update(
            projectManifest: sceneEditManager.projectManifest,
            sceneRef: sceneRef,
            sceneManifest: sceneEditManager.sceneManifest,
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
        
        animEditorVC?.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
        
//        if !fromEditor {
//            animEditorVC?.update(
//                projectManifest: projectManifest,
//                sceneManifest: sceneManifest)
//        }
    }
    
    // MARK: - Navigation
    
    private func showLayerEditor(layerID: String) {
//        guard
//            let delegate,
//            let projectManifest,
//            let sceneManifest
//        else { return }
//        
//        guard let layer = sceneManifest.layers
//            .first(where: { $0.id == layerID })
//        else { return }
//        
//        let availableUndoCount = delegate.availableUndoCount(self)
//        let availableRedoCount = delegate.availableRedoCount(self)
//        
//        switch layer.content {
//        case .animation:
//            let vc = AnimEditorVC(
//                projectID: projectID,
//                sceneID: sceneID,
//                activeLayerID: layerID,
//                activeFrameIndex: 0,
//                projectManifest: projectManifest,
//                sceneManifest: sceneManifest)
//            
//            vc.delegate = self
//            
//            vc.update(
//                availableUndoCount: availableUndoCount,
//                availableRedoCount: availableRedoCount)
//            
//            present(vc, animated: true)
//            animEditorVC = vc
//        }
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest
    ) {
//        guard let sceneRef = projectManifest
//            .content.sceneRefs
//            .first(where: { $0.id == sceneID })
//        else {
//            dismiss(animated: true)
//            return
//        }
//        
//        let sceneManifestURL = FileHelper.shared
//            .projectAssetURL(
//                projectID: projectID,
//                assetID: sceneRef.manifestAssetID)
//            
//        guard let sceneManifestData = try? Data(
//            contentsOf: sceneManifestURL)
//        else { return }
//        
//        guard let sceneManifest = try? JSONFileDecoder
//            .shared.decode(
//                Scene.Manifest.self,
//                from: sceneManifestData)
//        else { return }
//        
//        self.projectManifest = projectManifest
//        self.sceneRef = sceneRef
//        self.sceneManifest = sceneManifest
//        
//        handleUpdateData(fromEditor: false)
    }
    
}

// MARK: - Delegates

extension SceneEditorVC: SceneEditorContentVCDelegate {
    
    func onSelectBack(_ vc: SceneEditorContentVC) {
        dismiss(animated: true)
    }
    
    func onSelectAddLayer(_ vc: SceneEditorContentVC) { 
//        guard let sceneManifest else { return }
//        
//        let drawings = (0 ..< 10).map { index in
//            Scene.Drawing(
//                id: IDGenerator.id(),
//                frameIndex: index,
//                assetIDs: nil)
//        }
//        
//        let animationLayerContent = Scene.AnimationLayerContent(
//            drawings: drawings)
//        
//        let transform = Matrix3.identity
//        
//        let layer = Scene.Layer(
//            id: IDGenerator.id(),
//            name: "Animation Layer",
//            content: .animation(animationLayerContent),
//            contentSize: newLayerContentSize,
//            transform: transform,
//            alpha: 1)
//        
//        var newSceneManifest = sceneManifest
//        newSceneManifest.layers.append(layer)
//        
//        delegate?.applySceneEdit(
//            self,
//            sceneID: sceneID,
//            newSceneManifest: newSceneManifest,
//            newSceneAssets: [])
//        
//        self.sceneManifest = newSceneManifest
//        
//        handleUpdateData(fromEditor: false)
    }
    
    func onSelectRemoveLayer(_ vc: SceneEditorContentVC) {
//        guard let sceneManifest else { return }
//        
//        guard !sceneManifest.layers.isEmpty else { return }
//        
//        var newSceneManifest = sceneManifest
//        newSceneManifest.layers.removeLast()
//        
//        delegate?.applySceneEdit(
//            self,
//            sceneID: sceneID,
//            newSceneManifest: newSceneManifest,
//            newSceneAssets: [])
//        
//        self.sceneManifest = newSceneManifest
//        
//        handleUpdateData(fromEditor: false)
    }
    
    func onSelectUndo(_ vc: SceneEditorContentVC) { 
        delegate?.undo(self)
    }
    
    func onSelectRedo(_ vc: SceneEditorContentVC) {
        delegate?.redo(self)
    }
    
    func onSelectLayer(
        _ vc: SceneEditorContentVC,
        layerID: String
    ) {
        showLayerEditor(layerID: layerID)
    }
    
}

extension SceneEditorVC: AnimEditorVCDelegate {
    
    func onRequestUndo(_ vc: AnimEditorVC) {
        delegate?.undo(self)
    }
    func onRequestRedo(_ vc: AnimEditorVC) {
        delegate?.redo(self)
    }
    
    func onRequestApplyEdit(
        _ vc: AnimEditorVC,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditManager.NewAsset]
    ) {
//        self.sceneManifest = newSceneManifest
//        
//        delegate?.applySceneEdit(
//            self,
//            sceneID: sceneID,
//            newSceneManifest: newSceneManifest,
//            newSceneAssets: newSceneAssets)
//        
//        // TODO: what happens now?
//        
//        handleUpdateData(fromEditor: true)
    }
    
}
