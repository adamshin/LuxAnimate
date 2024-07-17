//
//  SceneRenderManifestGenerator.swift
//

import Foundation

struct SceneRenderManifestGenerator {
    
    static func generate(
        contentMetadata: Project.ContentMetadata,
        sceneManifest: Scene.Manifest
    ) -> Scene.RenderManifest {
        
        var sceneRenderManifest = Scene.RenderManifest(
            frameRenderManifests: [:],
            frameRenderManifestFingerprintsByFrameIndex: [])
        
        let layerProviders = sceneManifest.layers.map {
            Self.createSceneLayerProvider(
                sceneManifest: sceneManifest,
                layer: $0)
        }
        
        for frameIndex in 0 ..< sceneManifest.frameCount {
            var frameRenderManifest = Scene.FrameRenderManifest(
                viewportSize: contentMetadata.viewportSize,
                backgroundColor: sceneManifest.backgroundColor,
                layers: [])
            
            for layerProvider in layerProviders {
                if let layer = layerProvider.layer(at: frameIndex) {
                    frameRenderManifest.layers.append(layer)
                }
            }
            
            let fingerprint = frameRenderManifest.fingerprint()
            
            sceneRenderManifest
                .frameRenderManifests[fingerprint] = frameRenderManifest
            sceneRenderManifest
                .frameRenderManifestFingerprintsByFrameIndex.append(fingerprint)
        }
        
        return sceneRenderManifest
    }
    
    private static func createSceneLayerProvider(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer
    ) -> any FrameLayerProvider {
        
        switch layer.content {
        case .animation(let layerContent):
            return AnimationFrameLayerProvider(
                layer: layer,
                layerContent: layerContent)
        }
    }
    
}

// MARK: - Layer Provider

private protocol FrameLayerProvider {
    
    func layer(
        at frameIndex: Int
    ) -> Scene.FrameRenderManifest.Layer?
    
}

private struct AnimationFrameLayerProvider: FrameLayerProvider {
    
    private let layerSize: PixelSize
    
    private let sortedDrawings: [Scene.Drawing]
    private let frameIndexesToSortedDrawingIndexes: [Int?]
    
    init(
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent
    ) {
        self.layerSize = layer.size
        
        sortedDrawings = layerContent.drawings.sorted(
            using: KeyPathComparator(\.frameIndex))
        
        let maxFrameIndex = sortedDrawings.last?.frameIndex ?? 0
        
        var frameIndexesToSortedDrawingIndexes = Array<Int?>(
            repeating: nil,
            count: maxFrameIndex + 1)
        
        for (index, drawing) in sortedDrawings.enumerated() {
            let startFrameIndex = drawing.frameIndex
            
            let endFrameIndex = if index < sortedDrawings.count - 1 {
                sortedDrawings[index + 1].frameIndex
            } else {
                maxFrameIndex + 1
            }
            
            for frameIndex in startFrameIndex ..< endFrameIndex {
                frameIndexesToSortedDrawingIndexes[frameIndex] = index
            }
        }
        self.frameIndexesToSortedDrawingIndexes = frameIndexesToSortedDrawingIndexes
    }
    
    func layer(
        at frameIndex: Int
    ) -> Scene.FrameRenderManifest.Layer? {
        
        let adjustedFrameIndex = clamp(
            frameIndex,
            min: 0,
            max: frameIndexesToSortedDrawingIndexes.count - 1)
        
        guard let sortedDrawingIndex =
            frameIndexesToSortedDrawingIndexes[adjustedFrameIndex]
        else { return nil }
        
        let drawing = sortedDrawings[sortedDrawingIndex]
        
        guard let assetIDs = drawing.assetIDs else {
            return nil
        }
        
        let drawingContent = Scene.FrameRenderManifest
            .DrawingLayerContent(assetIDs: assetIDs)
        
        return Scene.FrameRenderManifest.Layer(
            size: layerSize,
            content: .drawing(drawingContent))
    }
    
}
