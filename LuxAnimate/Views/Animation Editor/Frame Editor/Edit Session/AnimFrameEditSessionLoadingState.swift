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
    
    private let sceneGraph: AnimFrameEditorSceneGraph
    private let editorToolState: AnimEditorToolState?

    private var loadStartTime: TimeInterval = 0

    weak var delegate: AnimFrameEditSessionStateDelegate?

    // MARK: - Init

    init(
        sceneGraph: AnimFrameEditorSceneGraph,
        editorToolState: AnimEditorToolState?
    ) {
        self.sceneGraph = sceneGraph
        self.editorToolState = editorToolState
    }
    
    // MARK: - Logic
    
    private func beginActiveState() {
        let newState = AnimFrameEditSessionActiveState(
            sceneGraph: sceneGraph,
            editorToolState: editorToolState)

        delegate?.changeState(self, newState: newState)
    }
    
    // MARK: - Interface
    
    func begin() {
//        delegate?.setEditInteractionEnabled(
//            self, enabled: false)

        loadStartTime = ProcessInfo.processInfo.systemUptime

        delegate?.loadAssets(self, assetIDs: sceneGraph.assetIDs)
    }
    
    func onFrame() -> EditorWorkspaceSceneGraph? { nil }
    
    func onAssetLoaderUpdate() {
        guard let delegate else { return }

        if delegate.hasLoadedAssets(
            self, assetIDs: sceneGraph.assetIDs)
        {
//            let loadEndTime = ProcessInfo.processInfo.systemUptime
//            let loadTime = loadEndTime - loadStartTime
//            let loadTimeMs = Int(loadTime * 1000)
//            print("Loaded assets. \(loadTimeMs) ms")

            beginActiveState()
        }
    }
    
}
