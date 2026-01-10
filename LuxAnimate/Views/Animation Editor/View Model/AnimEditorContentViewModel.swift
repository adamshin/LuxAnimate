//
//  AnimEditorContentViewModel.swift
//

import Foundation

struct AnimEditorContentViewModel {
    
    var projectID: String
    var layerID: String
    
    var projectManifest: Project.Manifest
    var sceneManifest: Scene.Manifest
    
    var availableUndoCount: Int
    var availableRedoCount: Int
    
    var layer: Scene.Layer
    var layerContent: Scene.AnimationLayerContent
    
    var timelineViewModel: AnimEditorTimelineViewModel
    
}

extension AnimEditorContentViewModel {
    
    enum InitializationError: Swift.Error {
        case invalidLayerID
        case invalidLayerType
    }
    
    init(
        projectID: String,
        layerID: String,
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        availableUndoCount: Int,
        availableRedoCount: Int
    ) throws {
        
        self.projectID = projectID
        self.layerID = layerID
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
        
        self.timelineViewModel =
            AnimEditorTimelineViewModel(
                projectID: projectID,
                sceneManifest: sceneManifest,
                layerContent: layerContent)
    }
    
}
