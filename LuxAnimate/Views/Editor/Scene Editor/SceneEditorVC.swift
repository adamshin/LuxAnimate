//
//  SceneEditorVC.swift
//

import UIKit

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

protocol SceneEditorVCDelegate: AnyObject {
    
    func availableUndoCount(_ vc: SceneEditorVC) -> Int
    func availableRedoCount(_ vc: SceneEditorVC) -> Int
    
    func onRequestUndo(_ vc: SceneEditorVC)
    func onRequestRedo(_ vc: SceneEditorVC)
    
    func onRequestApplyEdit(
        _ vc: SceneEditorVC,
        sceneID: String,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset])
    
}

class SceneEditorVC: UIViewController {
    
    weak var delegate: SceneEditorVCDelegate?
    
    private let contentVC = SceneEditorContentVC()
    
    private let projectID: String
    private let sceneID: String
    
    private var projectManifest: Project.Manifest?
    private var sceneRef: Project.SceneRef?
    private var sceneManifest: Scene.Manifest?
    
    private weak var animEditorVC: AnimEditorVC?
    
    // MARK: - Init
    
    init(projectID: String, sceneID: String) {
        self.projectID = projectID
        self.sceneID = sceneID
        
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
        guard
            let delegate,
            let projectManifest,
            let sceneRef,
            let sceneManifest
        else { return }
        
        let availableUndoCount = delegate.availableUndoCount(self)
        let availableRedoCount = delegate.availableRedoCount(self)
        
        contentVC.update(
            projectManifest: projectManifest,
            sceneRef: sceneRef,
            sceneManifest: sceneManifest,
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
        
        animEditorVC?.update(
            availableUndoCount: availableUndoCount,
            availableRedoCount: availableRedoCount)
        
        if !fromEditor {
            animEditorVC?.update(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest)
        }
    }
    
    // MARK: - Navigation
    
    private func showLayerEditor(layerID: String) {
        guard
            let delegate,
            let projectManifest,
            let sceneManifest
        else { return }
        
        guard let layer = sceneManifest.layers
            .first(where: { $0.id == layerID })
        else { return }
        
        let availableUndoCount = delegate.availableUndoCount(self)
        let availableRedoCount = delegate.availableRedoCount(self)
        
        switch layer.content {
        case .animation:
            let vc = AnimEditorVC(
                projectID: projectID,
                sceneID: sceneID,
                activeLayerID: layerID,
                activeFrameIndex: 0)
            
            vc.delegate = self
            
            vc.update(
                projectManifest: projectManifest,
                sceneManifest: sceneManifest)
            
            vc.update(
                availableUndoCount: availableUndoCount,
                availableRedoCount: availableRedoCount)
            
            present(vc, animated: true)
            animEditorVC = vc
        }
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest
    ) {
        guard let sceneRef = projectManifest
            .content.sceneRefs
            .first(where: { $0.id == sceneID })
        else {
            dismiss(animated: true)
            return
        }
        
        let sceneManifestURL = FileHelper.shared
            .projectAssetURL(
                projectID: projectID,
                assetID: sceneRef.manifestAssetID)
            
        guard let sceneManifestData = try? Data(
            contentsOf: sceneManifestURL)
        else { return }
        
        guard let sceneManifest = try? JSONFileDecoder
            .shared.decode(
                Scene.Manifest.self,
                from: sceneManifestData)
        else { return }
        
        self.projectManifest = projectManifest
        self.sceneRef = sceneRef
        self.sceneManifest = sceneManifest
        
        handleUpdateData(fromEditor: false)
    }
    
}

// MARK: - Delegates

extension SceneEditorVC: SceneEditorContentVCDelegate {
    
    func onSelectBack(_ vc: SceneEditorContentVC) {
        dismiss(animated: true)
    }
    
    func onSelectAddLayer(_ vc: SceneEditorContentVC) { 
        guard let sceneManifest else { return }
        
        let layerContent = Scene.AnimationLayerContent(
            drawings: [])
        
        let layer = Scene.Layer(
            id: IDGenerator.id(),
            name: "Animation Layer",
            content: .animation(layerContent),
            contentSize: newLayerContentSize,
            transform: .identity,
            alpha: 1)
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.append(layer)
        
        delegate?.onRequestApplyEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: [])
        
        self.sceneManifest = newSceneManifest
        
        handleUpdateData(fromEditor: false)
    }
    
    func onSelectRemoveLayer(_ vc: SceneEditorContentVC) {
        guard let sceneManifest else { return }
        
        guard !sceneManifest.layers.isEmpty else { return }
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.removeLast()
        
        delegate?.onRequestApplyEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: [])
        
        self.sceneManifest = newSceneManifest
        
        handleUpdateData(fromEditor: false)
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

extension SceneEditorVC: AnimEditorVCDelegate {
    
    func onRequestUndo(_ vc: AnimEditorVC) {
        delegate?.onRequestUndo(self)
    }
    func onRequestRedo(_ vc: AnimEditorVC) {
        delegate?.onRequestRedo(self)
    }
    
    func onRequestApplyEdit(
        _ vc: AnimEditorVC,
        newSceneManifest: Scene.Manifest,
        newSceneAssets: [ProjectEditor.Asset]
    ) {
        self.sceneManifest = newSceneManifest
        
        delegate?.onRequestApplyEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: newSceneAssets)
        
        handleUpdateData(fromEditor: true)
    }
    
}
