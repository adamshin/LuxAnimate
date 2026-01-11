//
//  AnimEditorModel.swift
//

import Foundation

struct AnimEditorModel {
    
    var projectManifest: Project.Manifest
    var sceneManifest: Scene.Manifest
    var layer: Scene.Layer
    var layerContent: Scene.AnimationLayerContent
    
    var timelineModel: AnimEditorTimelineModel
    
    var availableUndoCount: Int
    var availableRedoCount: Int
    
}

extension AnimEditorModel {
    
    enum InitializationError: Swift.Error {
        case invalidLayerID
        case invalidLayerType
    }
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layerID: String,
        availableUndoCount: Int,
        availableRedoCount: Int
    ) throws {
        
        self.projectManifest = projectManifest
        self.sceneManifest = sceneManifest
        self.availableUndoCount = availableUndoCount
        self.availableRedoCount = availableRedoCount
        
        guard let layer = sceneManifest.layers
            .first(where: { $0.id == layerID })
        else {
            throw InitializationError.invalidLayerID
        }
        
        guard case .animation(let layerContent)
            = layer.content
        else {
            throw InitializationError.invalidLayerType
        }
        
        self.layer = layer
        self.layerContent = layerContent
        
        self.timelineModel = .init(
            sceneManifest: sceneManifest,
            layerContent: layerContent)
    }
    
}
