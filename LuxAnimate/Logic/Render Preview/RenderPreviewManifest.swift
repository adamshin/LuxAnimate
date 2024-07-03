//
//  RenderPreviewManifest.swift
//

import Foundation

/*

struct RenderPreviewManifest {
    
    struct FrameLocation: Hashable {
        var sceneID: String
        var frameIndex: Int
    }
    
    var frameSceneGraphs: [FrameLocation: (RenderPreviewFrameSceneGraph, String)]
    var fingerprints: Set<String>
    
}

// MARK: - Generation

extension RenderPreviewManifest {
    
    static func generate(
        projectManifest: Project.Manifest
    ) -> RenderPreviewManifest {
        
        let metadata = projectManifest.metadata
        
        var previewManifest = RenderPreviewManifest(
            frameSceneGraphs: [:],
            fingerprints: [])
        
        for scene in projectManifest.content.scenes {
            var layerProviders = scene.layers.map {
                Self.createSceneLayerProvider(
                    scene: scene,
                    layer: $0)
            }
            
            for frameIndex in 0 ..< scene.frameCount {
                var frameSceneGraph = RenderPreviewFrameSceneGraph(
                    viewportSize: metadata.viewportSize,
                    backgroundColor: scene.backgroundColor,
                    layers: [])
                
                for layerProvider in layerProviders {
                    if let layer = layerProvider.layer(at: frameIndex) {
                        frameSceneGraph.layers.append(layer)
                    }
                }
                    
                let fingerprint = frameSceneGraph.fingerprint()
                        
                let frameLocation = FrameLocation(
                    sceneID: scene.id,
                    frameIndex: frameIndex)
                
                previewManifest.frameSceneGraphs[frameLocation]
                    = (frameSceneGraph, fingerprint)
                
                previewManifest.fingerprints.insert(fingerprint)
            }
        }
        
        return previewManifest
    }
    
    private static func createSceneLayerProvider(
        scene: Project.Scene,
        layer: Project.SceneLayer
    ) -> any SceneLayerProvider {
        
        switch layer.content {
        case .animation(let content):
            return AnimationSceneLayerProvider(
                scene: scene,
                content: content)
        }
    }
    
}

// MARK: - Scene Layer Provider

private protocol SceneLayerProvider {
    
    func layer(
        at frameIndex: Int
    ) -> RenderPreviewFrameSceneGraph.Layer?
    
}

private struct AnimationSceneLayerProvider: SceneLayerProvider {
    
    private let scene: Project.Scene
    private let content: Project.AnimationSceneLayerContent
    
    private let sortedDrawings: [Project.Drawing]
    private let frameIndexesToSortedDrawingIndexes: [Int?]
    
    init(
        scene: Project.Scene,
        content: Project.AnimationSceneLayerContent
    ) {
        self.scene = scene
        self.content = content
        
        sortedDrawings = content.drawings.sorted(
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
    ) -> RenderPreviewFrameSceneGraph.Layer? {
        
        guard let sortedDrawingIndex =
            frameIndexesToSortedDrawingIndexes[frameIndex]
        else { return nil }
        
        let drawing = sortedDrawings[sortedDrawingIndex]
        
        let drawingContent = RenderPreviewFrameSceneGraph.DrawingLayerContent(
            assetID: drawing.assetIDs.medium)
        
        return RenderPreviewFrameSceneGraph.Layer(
            size: content.size,
            content: .drawing(drawingContent))
    }
    
}
*/
