//
//  FrameSceneGraphBuilder.swift
//

import Foundation
import Geometry

struct FrameSceneGraphBuilder {
    
    static func build(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        frameIndex: Int
    ) -> FrameSceneGraph {
        
        let sceneGraphs = build(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndexes: [frameIndex])
        
        return sceneGraphs.first!
    }
    
    static func build(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        frameIndexes: [Int]
    ) -> [FrameSceneGraph] {
        
        let metadata = projectManifest.content.metadata
        let contentSize = Size(metadata.viewportSize)
        
        let sceneGraphLayerProviders = sceneManifest.layers.map {
            Self.sceneGraphLayerProvider(
                sceneManifest: sceneManifest,
                layer: $0)
        }
        
        var sceneGraphs: [FrameSceneGraph] = []
        
        for frameIndex in frameIndexes {
            var sceneGraph = FrameSceneGraph(
                contentSize: contentSize,
                backgroundColor: sceneManifest.backgroundColor,
                layers: [])
            
            for sceneGraphLayerProvider in sceneGraphLayerProviders {
                if let sceneGraphLayer = sceneGraphLayerProvider
                    .sceneGraphLayer(at: frameIndex)
                {
                    sceneGraph.layers.append(sceneGraphLayer)
                }
            }
            
            sceneGraphs.append(sceneGraph)
        }
        
        return sceneGraphs
    }
    
    private static func sceneGraphLayerProvider(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer
    ) -> SceneGraphLayerProvider {
        
        switch layer.content {
        case .animation(let layerContent):
            return AnimationSceneGraphLayerProvider(
                sceneManifest: sceneManifest,
                layer: layer,
                layerContent: layerContent)
        }
    }
    
}

// MARK: - Layer Providers

private protocol SceneGraphLayerProvider {
    
    func sceneGraphLayer(
        at frameIndex: Int
    ) -> FrameSceneGraph.Layer?
    
}

private struct AnimationSceneGraphLayerProvider: SceneGraphLayerProvider {
    
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    
    private let sortedDrawings: [Scene.Drawing]
    private let frameIndexesToSortedDrawingIndexes: [Int: Int]
    
    init(
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent
    ) {
        self.layer = layer
        self.layerContent = layerContent
        
        sortedDrawings = layerContent.drawings.sorted(
            using: KeyPathComparator(\.frameIndex))
        
        let maxFrameIndex = sceneManifest.frameCount - 1
        
        var frameIndexesToSortedDrawingIndexes: [Int: Int] = [:]
        
        for (drawingIndex, drawing) in sortedDrawings.enumerated() {
            let startFrameIndex = drawing.frameIndex
            
            let endFrameIndex = if drawingIndex < sortedDrawings.count - 1 {
                sortedDrawings[drawingIndex + 1].frameIndex
            } else {
                maxFrameIndex + 1
            }
            
            for frameIndex in startFrameIndex ..< endFrameIndex {
                frameIndexesToSortedDrawingIndexes[frameIndex] = drawingIndex
            }
        }
        self.frameIndexesToSortedDrawingIndexes = frameIndexesToSortedDrawingIndexes
    }
    
    func sceneGraphLayer(
        at frameIndex: Int
    ) -> FrameSceneGraph.Layer? {
        
        guard let sortedDrawingIndex =
            frameIndexesToSortedDrawingIndexes[frameIndex]
        else { return nil }
        
        let drawing = sortedDrawings[sortedDrawingIndex]
        
        let content = FrameSceneGraph.DrawingLayerContent(
            drawing: drawing)
        
        return FrameSceneGraph.Layer(
            content: .drawing(content),
            contentSize: Size(layer.contentSize),
            transform: layer.transform,
            alpha: layer.alpha)
    }
    
}
