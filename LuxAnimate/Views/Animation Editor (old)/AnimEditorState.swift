//
//  AnimEditorState.swift
//

import Foundation

// Need to re-evaluate this. There's a lot of stuff
// inside here. Including tool selection - does that
// make sense? This might be better conceived as a view
// model that represents the timeline and selected
// frame, but not tool state. Maybe not the project edit
// state either - which really just contains the project
// manifest plus undo/redo count.
    
struct AnimEditorState {
    
    enum Tool {
        case paint
        case erase
    }
    
    let projectID: String
    let layerID: String
    
    var projectState: ProjectEditManager.State
    var sceneManifest: Scene.Manifest
    var layer: Scene.Layer
    var layerContent: Scene.AnimationLayerContent
    
    var focusedFrameIndex: Int
    
    var onionSkinOn: Bool
    var onionSkinConfig: AnimEditorOnionSkinConfig
    
    var selectedTool: Tool
    
//    var timelineModel: AnimEditorTimelineModel
    
}

extension AnimEditorState {
    
    struct Update {
        var state: AnimEditorState
        var changes: Changes
    }
    
    struct Changes {
        var projectState: Bool = false
        var focusedFrameIndex: Bool = false
        var onionSkin: Bool = false
        var selectedTool: Bool = false
        var timelineModel: Bool = false
    }
    
}

extension AnimEditorState {
    
    // MARK: - Init
    
    init(
        projectID: String,
        layerID: String,
        projectState: ProjectEditManager.State,
        sceneManifest: Scene.Manifest,
        focusedFrameIndex: Int,
        onionSkinOn: Bool,
        onionSkinConfig: AnimEditorOnionSkinConfig,
        selectedTool: Tool
    ) throws {
        
        let (layer, layerContent) =
            try Self.layerData(
                sceneManifest: sceneManifest,
                layerID: layerID)
        
        let focusedFrameIndex =
            Self.clampedFocusedFrameIndex(
                focusedFrameIndex: focusedFrameIndex,
                sceneManifest: sceneManifest)
        
//        let timelineModel = AnimEditorTimelineModel.generate(
//            projectID: projectID,
//            sceneManifest: sceneManifest,
//            layerContent: layerContent)
        
        self.projectID = projectID
        self.layerID = layerID
        self.projectState = projectState
        self.sceneManifest = sceneManifest
        self.layer = layer
        self.layerContent = layerContent
        self.focusedFrameIndex = focusedFrameIndex
        self.onionSkinOn = onionSkinOn
        self.onionSkinConfig = onionSkinConfig
//        self.timelineModel = timelineModel
        self.selectedTool = selectedTool
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
    ) throws -> Update {
        
        let (layer, layerContent) =
            try Self.layerData(
                sceneManifest: sceneManifest,
                layerID: layerID)
        
        let focusedFrameIndex =
            Self.clampedFocusedFrameIndex(
                focusedFrameIndex: focusedFrameIndex,
                sceneManifest: sceneManifest)
        
//        let timelineModel = AnimEditorTimelineModel.generate(
//            projectID: projectID,
//            sceneManifest: sceneManifest,
//            layerContent: layerContent)
        
        var state = self
        state.projectState = projectState
        state.sceneManifest = sceneManifest
        state.layer = layer
        state.layerContent = layerContent
        state.focusedFrameIndex = focusedFrameIndex
//        state.timelineModel = timelineModel
        
        let changes = Changes(
            projectState: true,
            focusedFrameIndex: true,
            timelineModel: true)
        
        return Update(state: state, changes: changes)
    }
    
    func update(
        focusedFrameIndex: Int
    ) -> Update {
        
        var state = self
        let oldIndex = state.focusedFrameIndex
        
        state.focusedFrameIndex = Self.clampedFocusedFrameIndex(
            focusedFrameIndex: focusedFrameIndex,
            sceneManifest: sceneManifest)
        
        let newIndex = state.focusedFrameIndex
        let indexChanged = oldIndex != newIndex
        
        let changes = Changes(
            focusedFrameIndex: indexChanged)
        
        return Update(state: state, changes: changes)
    }
    
    func update(
        onionSkinOn: Bool
    ) -> Update {
        
        var state = self
        state.onionSkinOn = onionSkinOn
        
        let changes = Changes(
            onionSkin: true)
        
        return Update(state: state, changes: changes)
    }
    
    func update(
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> Update {
        
        var state = self
        state.onionSkinConfig = onionSkinConfig
        
        let changes = Changes(
            onionSkin: true)
        
        return Update(state: state, changes: changes)
    }
    
    func update(
        selectedTool: Tool
    ) -> Update {
        
        var state = self
        state.selectedTool = selectedTool
        
        let changes = Changes(
            selectedTool: true)
        
        return Update(state: state, changes: changes)
    }
    
}

// MARK: - Layer Reader

extension AnimEditorState {
    
    enum LayerDataError: Swift.Error {
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
            throw LayerDataError.invalidLayerID
        }
        
        guard case .animation(let content)
            = layer.content
        else {
            throw LayerDataError.invalidLayerContent
        }
        
        return (layer, content)
    }
    
}
