//
//  AnimEditorLayerReader.swift
//

import Foundation

struct AnimEditorLayerReader {
    
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
