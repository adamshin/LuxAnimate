//
//  AnimEditorState.swift
//

import Foundation
    
struct AnimEditorState {
    
    let projectID: String
    let layerID: String
    
    var projectState: ProjectEditManager.State
    var sceneManifest: Scene.Manifest
    var layer: Scene.Layer
    var layerContent: Scene.AnimationLayerContent
    
    var focusedFrameIndex: Int
    var onionSkinConfig: AnimEditorOnionSkinConfig
    
    var timelineModel: AnimEditorTimelineModel
    
}

extension AnimEditorState {
    
    // MARK: - Init
    
    init(
        projectID: String,
        layerID: String,
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        focusedFrameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) throws {
        
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
        
        self.projectID = projectID
        self.layerID = layerID
        self.projectState = projectState
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.focusedFrameIndex = focusedFrameIndex
        self.onionSkinConfig = onionSkinConfig
        self.timelineModel = timelineModel
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
    
    mutating func update(
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest
    ) throws {
        
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
        
        self.projectState = projectState
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.focusedFrameIndex = focusedFrameIndex
        self.timelineModel = timelineModel
    }
    
    mutating func update(
        focusedFrameIndex: Int
    ) {
        self.focusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: focusedFrameIndex,
            sceneManifest: sceneManifest)
    }
    
    mutating func update(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) {
        self.onionSkinConfig = onionSkinConfig
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
