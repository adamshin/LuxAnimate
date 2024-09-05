//
//  AnimFrameEditorLoadingState.swift
//

import Metal

class AnimFrameEditorLoadingState: AnimFrameEditorState {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
    }
    
    private let projectID: String
    private let sceneID: String
    private let activeLayerID: String
    private let activeFrameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let animationLayerContent: Scene.AnimationLayerContent
    
    private let editorToolState: AnimEditorToolState
    
    private let frameSceneGraph: FrameSceneGraph
    
    private let activeDrawingManifest:
        AnimFrameEditorHelper.ActiveDrawingManifest
    
    private let assetManifest:
        AnimFrameEditorHelper.AssetManifest
    
    private var hasLoadedAllAssets = false
    
    weak var delegate: AnimFrameEditorStateDelegate?
    
    // MARK: - Init
    
    init(
        projectID: String,
        sceneID: String,
        activeLayerID: String,
        activeFrameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        editorToolState: AnimEditorToolState
    ) throws {
        
        guard let layer = sceneManifest.layers.first(
            where: { $0.id == sceneID })
        else {
            throw Error.invalidLayerID
        }
        
        guard case .animation(let animationLayerContent)
            = layer.content
        else {
            throw Error.invalidLayerContent
        }
        
        self.projectID = projectID
        self.sceneID = sceneID
        self.activeLayerID = activeLayerID
        self.activeFrameIndex = activeFrameIndex
        self.onionSkinConfig = onionSkinConfig
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.animationLayerContent = animationLayerContent
        
        self.editorToolState = editorToolState
        
        frameSceneGraph = FrameSceneGraphGenerator.generate(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndex: activeFrameIndex)
        
        activeDrawingManifest = AnimFrameEditorHelper
            .activeDrawingManifest(
                animationLayerContent: animationLayerContent,
                frameIndex: activeFrameIndex,
                onionSkinConfig: onionSkinConfig)
        
        assetManifest = AnimFrameEditorHelper
            .assetManifest(
                frameSceneGraph: frameSceneGraph,
                activeDrawingManifest: activeDrawingManifest)
    }
    
    // MARK: - Logic
    
    private func enterEditingState() {
        let newState = AnimFrameEditorEditingState(
            projectID: projectID,
            sceneID: sceneID,
            activeLayerID: activeLayerID,
            activeFrameIndex: activeFrameIndex,
            onionSkinConfig: onionSkinConfig,
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            animationLayerContent: animationLayerContent,
            editorToolState: editorToolState,
            frameSceneGraph: frameSceneGraph,
            activeDrawingManifest: activeDrawingManifest,
            assetManifest: assetManifest)
        
        delegate?.changeState(self, newState: newState)
    }
    
    // MARK: - Interface
    
    func beginState() {
        delegate?.setEditInteractionEnabled(
            self, enabled: false)
        
        let assetIDsToLoad = assetManifest.allAssetIDs()
        
        delegate?.setAssetLoaderAssetIDs(
            self, assetIDs: assetIDsToLoad)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? { nil }
    
    func onLoadAsset() {
        let assetIDsToLoad = assetManifest.allAssetIDs()
        
        let allAssetsLoaded = !assetIDsToLoad.contains {
            delegate?.assetLoaderAssetTexture(
                self, assetID: $0) == nil
        }
        
        if allAssetsLoaded, !hasLoadedAllAssets {
            hasLoadedAllAssets = true
            enterEditingState()
        }
    }
    
}
