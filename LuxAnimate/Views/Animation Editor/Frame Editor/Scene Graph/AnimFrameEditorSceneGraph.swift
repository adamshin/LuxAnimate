//
//  AnimFrameEditorSceneGraph.swift
//

import Foundation
import Color

extension AnimFrameEditorSceneGraph {
    
    struct ActiveDrawingContext {
        let activeDrawing: Scene.Drawing?
        let onionSkinDrawings: [OnionSkinDrawing]
    }
    
    struct OnionSkinDrawing {
        let drawing: Scene.Drawing
        let tintColor: Color
        let alpha: Double
    }
    
}

struct AnimFrameEditorSceneGraph {
    
    var layer: Scene.Layer
    
    var frameSceneGraph: FrameSceneGraph
    var activeDrawingContext: ActiveDrawingContext
    
    var assetIDs: Set<String>
    
    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?
    ) {
        self.layer = layer
        
        frameSceneGraph = FrameSceneGraphBuilder.build(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndex: frameIndex)
        
        activeDrawingContext =
            Self.buildActiveDrawingContext(
                layerContent: layerContent,
                frameIndex: frameIndex,
                onionSkinConfig: onionSkinConfig)
        
        assetIDs = Self.collectAssetIDs(
            frameSceneGraph: frameSceneGraph,
            activeDrawingContext: activeDrawingContext)
    }
    
    private static func buildActiveDrawingContext(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?
    ) -> ActiveDrawingContext {
        
        let sortedDrawings = layerContent.drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let activeDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= frameIndex
        }
        
        guard let activeDrawingIndex else {
            return ActiveDrawingContext(
                activeDrawing: nil,
                onionSkinDrawings: [])
        }
        
        let activeDrawing = sortedDrawings[activeDrawingIndex]
        
        let onionSkinDrawings: [OnionSkinDrawing]
        
        if let config = onionSkinConfig {
            let prevDrawings = buildOnionSkinDrawings(
                sortedDrawings: sortedDrawings,
                activeDrawingIndex: activeDrawingIndex,
                direction: -1,
                count: config.prevCount,
                color: config.prevColor,
                alpha: config.alpha,
                alphaFalloff: config.alphaFalloff)
            
            let nextDrawings = buildOnionSkinDrawings(
                sortedDrawings: sortedDrawings,
                activeDrawingIndex: activeDrawingIndex,
                direction: 1,
                count: config.nextCount,
                color: config.nextColor,
                alpha: config.alpha,
                alphaFalloff: config.alphaFalloff)
            
            onionSkinDrawings = prevDrawings + nextDrawings
            
        } else {
            onionSkinDrawings = []
        }
        
        return ActiveDrawingContext(
            activeDrawing: activeDrawing,
            onionSkinDrawings: onionSkinDrawings)
    }
    
    private static func buildOnionSkinDrawings(
        sortedDrawings: [Scene.Drawing],
        activeDrawingIndex: Int,
        direction: Int,
        count: Int,
        color: Color,
        alpha: Double,
        alphaFalloff: Double
    ) -> [OnionSkinDrawing] {
        
        var drawings: [OnionSkinDrawing] = []
        var drawingIndex = activeDrawingIndex
        
        for i in 0 ..< count {
            drawingIndex += direction
            
            guard sortedDrawings.indices
                .contains(drawingIndex)
            else { continue }
            
            let drawing = sortedDrawings[drawingIndex]
            let layerAlpha = alpha - alphaFalloff * Double(i)
            let tintColor = color.withAlpha(layerAlpha)
            
            drawings.append(OnionSkinDrawing(
                drawing: drawing,
                tintColor: tintColor,
                alpha: layerAlpha))
        }
        
        return drawings
    }
    
    // MARK: - Asset Collection
    
    private static func collectAssetIDs(
        frameSceneGraph: FrameSceneGraph,
        activeDrawingContext: ActiveDrawingContext
    ) -> Set<String> {
        var assetIDs = Set<String>()
        
        for layer in frameSceneGraph.layers {
            switch layer.content {
            case .drawing(let content):
                if let assetID = content.drawing.fullAssetID {
                    assetIDs.insert(assetID)
                }
            }
        }
        
        if let assetID = activeDrawingContext.activeDrawing?.fullAssetID {
            assetIDs.insert(assetID)
        }
        
        for onionSkinDrawing in activeDrawingContext.onionSkinDrawings {
            if let assetID = onionSkinDrawing.drawing.fullAssetID {
                assetIDs.insert(assetID)
            }
        }
        
        return assetIDs
    }
    
}
