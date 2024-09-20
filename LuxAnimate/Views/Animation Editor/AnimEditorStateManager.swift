//
//  AnimEditorStateManager.swift
//

import Foundation

extension AnimEditorStateManager {
    
    struct State {
        var projectState: ProjectEditManager.State
        var sceneManifest: Scene.Manifest
        var layer: Scene.Layer
        var layerContent: Scene.AnimationLayerContent
        
        var focusedFrameIndex: Int
        var onionSkinConfig: AnimEditorOnionSkinConfig
        
        var timelineModel: AnimEditorTimelineModel
    }
    
}

@MainActor
class AnimEditorStateManager {
    
    private let projectID: String
    private let layerID: String
    
    private(set) var state: State
    
    // MARK: - Init
    
    init(
        projectID: String,
        layerID: String,
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        focusedFrameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) throws {
        
        self.projectID = projectID
        self.layerID = layerID
        
        let (layer, layerContent) =
            try LayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: layerID)
        
        let focusedFrameIndex =
            Self.clampedFocusedFrameIndex(
                focusedFrameIndex: focusedFrameIndex,
                sceneManifest: sceneManifest)
        
        let timelineModel = AnimEditorTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            layerContent: layerContent)
        
        state = State(
            projectState: projectState,
            sceneManifest: sceneManifest,
            layer: layer,
            layerContent: layerContent,
            focusedFrameIndex: focusedFrameIndex,
            onionSkinConfig: onionSkinConfig,
            timelineModel: timelineModel)
    }
    
    // MARK: - Internal Logic
    
    private static func clampedFocusedFrameIndex(
        focusedFrameIndex: Int,
        sceneManifest: Scene.Manifest
    ) -> Int {
        clamp(focusedFrameIndex,
            min: 0,
            max: sceneManifest.frameCount - 1)
    }
    
    // MARK: - Update
    
    func update(
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest
    ) throws {
        
        let (layer, layerContent) =
            try LayerReader.layerData(
                sceneManifest: sceneManifest,
                layerID: layerID)
        
        let focusedFrameIndex =
            Self.clampedFocusedFrameIndex(
                focusedFrameIndex: state.focusedFrameIndex,
                sceneManifest: sceneManifest)
        
        let timelineModel = AnimEditorTimelineModel.generate(
            projectID: projectID,
            sceneManifest: sceneManifest,
            layerContent: layerContent)
        
        state.projectState = projectState
        state.sceneManifest = sceneManifest
        state.layer = layer
        state.layerContent = layerContent
        state.focusedFrameIndex = focusedFrameIndex
        state.timelineModel = timelineModel
    }
    
    func update(
        focusedFrameIndex: Int
    ) {
        let focusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: focusedFrameIndex,
            sceneManifest: state.sceneManifest)
        
        state.focusedFrameIndex = focusedFrameIndex
    }
    
    func update(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) {
        state.onionSkinConfig = onionSkinConfig
    }
    
}

// MARK: - Layer Reader

private struct LayerReader {
    
    enum Error: Swift.Error {
        case invalidLayerID
        case invalidLayerContent
    }
    
    static func layerData(
        sceneManifest: Scene.Manifest,
        layerID: String
    ) throws -> (
        Scene.Layer,
        Scene.AnimationLayerContent
    ) {
        
        guard let layer = sceneManifest.layers.first(
            where: { $0.id == layerID })
        else {
            throw Error.invalidLayerID
        }
        
        guard case .animation(let content)
            = layer.content
        else {
            throw Error.invalidLayerContent
        }
        
        return (layer, content)
    }
    
}
