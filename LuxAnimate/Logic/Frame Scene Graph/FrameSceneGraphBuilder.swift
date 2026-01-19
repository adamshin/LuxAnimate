//
//  FrameSceneGraphBuilder.swift
//

import Foundation
import Geometry

struct FrameSceneGraphBuilder {

    static func build(
        projectManifest: Project.Manifest,
        frameIndex: Int
    ) -> FrameSceneGraph {

        let sceneGraphs = build(
            projectManifest: projectManifest,
            frameIndexes: [frameIndex])

        return sceneGraphs.first!
    }

    static func build(
        projectManifest: Project.Manifest,
        frameIndexes: [Int]
    ) -> [FrameSceneGraph] {

        let metadata = projectManifest.content.metadata
        let contentSize = Size(metadata.viewportSize)

        let sceneGraphLayerProviders = projectManifest.content.layers.map {
            Self.sceneGraphLayerProvider(
                projectManifest: projectManifest,
                layer: $0)
        }

        var sceneGraphs: [FrameSceneGraph] = []

        for frameIndex in frameIndexes {
            var sceneGraph = FrameSceneGraph(
                contentSize: contentSize,
                backgroundColor: metadata.backgroundColor,
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
        projectManifest: Project.Manifest,
        layer: Project.Layer
    ) -> SceneGraphLayerProvider {

        switch layer.content {
        case .animation(let layerContent):
            return AnimationSceneGraphLayerProvider(
                projectManifest: projectManifest,
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

    private let layer: Project.Layer
    private let layerContent: Project.AnimationLayerContent

    private let sortedDrawings: [Project.Drawing]
    private let frameIndexesToSortedDrawingIndexes: [Int: Int]

    init(
        projectManifest: Project.Manifest,
        layer: Project.Layer,
        layerContent: Project.AnimationLayerContent
    ) {
        self.layer = layer
        self.layerContent = layerContent

        sortedDrawings = layerContent.drawings.sorted(
            using: KeyPathComparator(\.frameIndex))

        let maxFrameIndex = projectManifest.content.metadata.frameCount - 1

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
