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
    private let editorToolState: AnimEditorToolState?

    private let editContext: AnimFrameEditContext
    
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
        self.editorToolState = editorToolState

        editContext = AnimFrameEditContext(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig)
    }
    
    // MARK: - Logic
    
    private func beginActiveState() {
        let newState = AnimFrameEditSessionActiveState(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            frameIndex: frameIndex,
            editorToolState: editorToolState,
            editContext: editContext)

        delegate?.changeState(self, newState: newState)
    }
    
    // MARK: - Interface
    
    func begin() {
//        delegate?.setEditInteractionEnabled(
//            self, enabled: false)

        loadStartTime = ProcessInfo.processInfo.systemUptime

        delegate?.loadAssets(self, assetIDs: editContext.assetIDs)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? { nil }
    
    func onAssetLoaderUpdate() {
        guard let delegate else { return }

        if delegate.hasLoadedAssets(
            self, assetIDs: editContext.assetIDs)
        {
//            let loadEndTime = ProcessInfo.processInfo.systemUptime
//            let loadTime = loadEndTime - loadStartTime
//            let loadTimeMs = Int(loadTime * 1000)
//            print("Loaded assets. \(loadTimeMs) ms")

            beginActiveState()
        }
    }
    
}
