//
//  FrameSceneGraphGenerator.swift
//

import Foundation

struct FrameSceneGraphGenerator {
    
    static func generate(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        frameIndex: Int
    ) -> FrameSceneGraph {
        
        let metadata = projectManifest.content.metadata
        
        let contentSize = Size(metadata.viewportSize)
        
        var sceneGraph = FrameSceneGraph(
            contentSize: contentSize,
            backgroundColor: sceneManifest.backgroundColor,
            layers: [])
        
        let layerProviders = sceneManifest.layers.map {
            Self.createLayerProvider(layer: $0)
        }
        
        for layerProvider in layerProviders {
            if let layer = layerProvider.layer(at: frameIndex) {
                sceneGraph.layers.append(layer)
            }
        }
        
        return sceneGraph
    }
    
    private static func createLayerProvider(
        layer: Scene.Layer
    ) -> LayerProvider {
        
        switch layer.content {
        case .animation(let layerContent):
            return AnimationLayerProvider(
                layer: layer,
                layerContent: layerContent)
        }
    }
    
}

// MARK: - Layer Providers

private protocol LayerProvider {
    
    func layer(
        at frameIndex: Int
    ) -> FrameSceneGraph.Layer?
    
}

private struct AnimationLayerProvider: LayerProvider {
    
    private let layer: Scene.Layer
    private let layerContent: Scene.AnimationLayerContent
    
    private let sortedDrawings: [Scene.Drawing]
    private let frameIndexesToSortedDrawingIndexes: [Int: Int]
    
    init(
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent
    ) {
        self.layer = layer
        self.layerContent = layerContent
        
        sortedDrawings = layerContent.drawings.sorted(
            using: KeyPathComparator(\.frameIndex))
        
        let maxFrameIndex = sortedDrawings.last?.frameIndex ?? 0
        
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
    
    func layer(
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
