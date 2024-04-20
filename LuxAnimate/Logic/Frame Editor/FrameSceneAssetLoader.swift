//
//  FrameSceneAssetLoader.swift
//

import Foundation
import Metal

class FrameSceneAssetLoader {
    
    struct LoadedImageAsset {
        var texture: MTLTexture
    }
    
    var loadedImageAssets: [String: LoadedImageAsset] = [:]
    
    func loadLayerAssets(
        projectID: String,
        scene: FrameScene
    ) async throws {
        
        let drawings = Self.drawings(from: scene.layers)
        
        for drawing in drawings {
            let texture = try ImageAssetLoader.load(
                projectID: projectID,
                assetID: drawing.assets.previewMedium)
            
            loadedImageAssets[drawing.id] = LoadedImageAsset(texture: texture)
        }
    }
    
    private static func drawings(
        from layers: [FrameScene.Layer]
    ) -> [Project.Drawing] {
        
        return layers.flatMap { layer in
            switch layer.content {
            case .drawing(let drawing):
                return [drawing]
                
//            case .group(let childLayers):
//                return drawings(from: childLayers)
            }
        }
    }
    
}
