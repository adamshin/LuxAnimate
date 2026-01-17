//
//  AnimFrameEditSessionLoadingState.swift
//

import Foundation

class AnimFrameEditSessionLoadingState:
    AnimFrameEditSessionState {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
    }
    
    private let projectManifest: Project.Manifest
    private let sceneManifest: Scene.Manifest
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    private let frameIndex: Int
    private let onionSkinConfig: AnimEditorOnionSkinConfig?
    private let editorToolState: AnimEditorToolState?
    
    private let frameSceneGraph: FrameSceneGraph
    
    private let activeDrawingManifest:
        AnimFrameEditorHelper.ActiveDrawingManifest
    
    private let assetManifest:
        AnimFrameEditorHelper.AssetManifest
    
    private let assetIDsToLoad: Set<String>
    
    private var loadStartTime: TimeInterval = 0
    
    weak var delegate: AnimFrameEditSessionStateDelegate?
    
    // MARK: - Init
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?,
        editorToolState: AnimEditorToolState?
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
        
        assetIDsToLoad = assetManifest.allAssetIDs()
    }
    
    // MARK: - Logic
    
    private func beginActiveState() {
        let newState = AnimFrameEditSessionActiveState(
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
    
    func begin() {
//        delegate?.setEditInteractionEnabled(
//            self, enabled: false)
        
        loadStartTime = ProcessInfo.processInfo.systemUptime
        
        delegate?.loadAssets(self, assetIDs: assetIDsToLoad)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? { nil }
    
    func onAssetLoaderUpdate() {
        guard let delegate else { return }
        
        if delegate.hasLoadedAssets(
            self, assetIDs: assetIDsToLoad)
        {
//            let loadEndTime = ProcessInfo.processInfo.systemUptime
//            let loadTime = loadEndTime - loadStartTime
//            let loadTimeMs = Int(loadTime * 1000)
//            print("Loaded assets. \(loadTimeMs) ms")
            
            beginActiveState()
        }
    }
    
}
