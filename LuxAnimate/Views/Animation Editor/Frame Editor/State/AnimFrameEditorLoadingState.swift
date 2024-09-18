//
//  AnimFrameEditorLoadingState.swift
//

import Metal

class AnimFrameEditorLoadingState: AnimFrameEditorState {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
    }
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    private let frameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig
    private let editorToolState: AnimEditorToolState
    
    private let frameSceneGraph: FrameSceneGraph
    
    private let activeDrawingManifest:
        AnimFrameEditorHelper.ActiveDrawingManifest
    
    private let assetManifest:
        AnimFrameEditorHelper.AssetManifest
    
    weak var delegate: AnimFrameEditorStateDelegate?
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        editorToolState: AnimEditorToolState
    ) {
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.frameIndex = frameIndex
        self.onionSkinConfig = onionSkinConfig
        self.editorToolState = editorToolState
        
        frameSceneGraph = FrameSceneGraphGenerator.generate(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndex: frameIndex)
        
        activeDrawingManifest = AnimFrameEditorHelper
            .activeDrawingManifest(
                layerContent: layerContent,
                frameIndex: frameIndex,
                onionSkinConfig: onionSkinConfig)
        
        assetManifest = AnimFrameEditorHelper
            .assetManifest(
                frameSceneGraph: frameSceneGraph,
                activeDrawingManifest: activeDrawingManifest)
    }
    
    // MARK: - Logic
    
    private func enterEditingState() {
        let newState = AnimFrameEditorEditingState(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig,
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
    
    func onAssetLoaderUpdate() { }
    
    func onAssetLoaderFinish() {
        enterEditingState()
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? { nil }
    
}
