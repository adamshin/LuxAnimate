//
//  SceneEditorVC.swift
//

import UIKit

private let newLayerContentSize = PixelSize(
    width: 1920, height: 1080)

protocol SceneEditorVCDelegate: AnyObject {
    
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
    
    private weak var animationEditorVC: AnimationEditorVC?
    
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
    
    private func updateContentVCModels() {
        guard
            let projectManifest,
            let sceneRef,
            let sceneManifest
        else { return }
        
        contentVC.update(
            projectManifest: projectManifest,
            sceneRef: sceneRef,
            sceneManifest: sceneManifest)
    }
    
    // MARK: - Interface
    
    func update(
        projectManifest: Project.Manifest
    ) {
        do {
            guard let sceneRef = projectManifest.content.sceneRefs
                .first(where: { $0.id == sceneID })
            else {
                dismiss(animated: true)
                return
            }
            
            let sceneManifestURL = FileHelper.shared
                .projectAssetURL(
                    projectID: projectID,
                    assetID: sceneRef.manifestAssetID)
            
            let sceneManifestData = try Data(
                contentsOf: sceneManifestURL)
            
            let sceneManifest = try JSONFileDecoder.shared.decode(
                Scene.Manifest.self,
                from: sceneManifestData)
            
            self.projectManifest = projectManifest
            self.sceneRef = sceneRef
            self.sceneManifest = sceneManifest
            
            updateContentVCModels()
            
            // TODO: Update animationEditorVC!
            
        } catch { }
    }
    
    func update(
        undoCount: Int,
        redoCount: Int
    ) {
        contentVC.update(
            undoCount: undoCount,
            redoCount: redoCount)
        
        // TODO: Update animationEditorVC!
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
            contentSize: newLayerContentSize,
            content: .animation(layerContent))
        
        var newSceneManifest = sceneManifest
        newSceneManifest.layers.append(layer)
        
        delegate?.onRequestApplyEdit(
            self,
            sceneID: sceneID,
            newSceneManifest: newSceneManifest,
            newSceneAssets: [])
        
        self.sceneManifest = newSceneManifest
        updateContentVCModels()
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
        updateContentVCModels()
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
        guard 
            let projectManifest,
            let sceneManifest
        else { return }
        
        guard let layer = sceneManifest.layers.first(
            where: { $0.id == layerID })
        else { return }
        
        switch layer.content {
        case .animation(let animationLayerContent):
            
            let projectViewportSize = projectManifest
                .content.metadata.viewportSize
            
            do {
                let vc = try AnimationEditorVC(
                    projectID: projectID,
                    layerID: layerID,
                    projectViewportSize: projectViewportSize,
                    layerContentSize: layer.contentSize,
                    animationLayerContent: animationLayerContent)
                
                present(vc, animated: true)
                
            } catch { }
        }
    }
    
}
