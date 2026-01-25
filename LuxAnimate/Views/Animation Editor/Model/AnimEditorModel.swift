//
//  AnimEditorModel.swift
//

import Foundation

struct AnimEditorModel {
    
    var projectManifest: Project.Manifest
    var layer: Project.Layer
    var layerContent: Project.AnimationLayerContent
    
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
        layerID: String,
        availableUndoCount: Int,
        availableRedoCount: Int
    ) throws {
        
        self.projectManifest = projectManifest
        self.availableUndoCount = availableUndoCount
        self.availableRedoCount = availableRedoCount
        
        guard let layer = projectManifest.content.layers
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
        
        let frameCount = projectManifest.content.metadata.frameCount
        self.timelineModel = .init(
            frameCount: frameCount,
            layerContent: layerContent)
    }
    
}
