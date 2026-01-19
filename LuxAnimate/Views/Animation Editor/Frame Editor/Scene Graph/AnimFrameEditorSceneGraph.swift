//
//  AnimFrameEditorSceneGraph.swift
//

import Foundation
import Color

/// Animation frame editor scene graph.
///
/// An intermediate scene graph representation for the animation frame editor. Built from a FrameSceneGraph,
/// this adds editor-specific information like which drawing is active (for live canvas replacement),
/// onion skin layers with pre-computed colors/alphas, and asset IDs for loading. Gets converted to
/// EditorWorkspaceSceneGraph for rendering.
struct AnimFrameEditorSceneGraph {

    let layer: Scene.Layer
    let frameSceneGraph: FrameSceneGraph
    let activeDrawingContext: ActiveDrawingContext
    let assetIDs: Set<String>

    // MARK: - Active Drawing Context

    /// The active drawing and its onion skin layers, with pre-computed rendering information.
    struct ActiveDrawingContext {

        /// A drawing to render as an onion skin layer, with pre-computed tint color and alpha.
        struct OnionSkinDrawing {
            let drawing: Scene.Drawing
            let tintColor: Color
            let alpha: Double
        }

        let activeDrawing: Scene.Drawing?
        let prevOnionSkinDrawings: [OnionSkinDrawing]
        let nextOnionSkinDrawings: [OnionSkinDrawing]
    }

    // MARK: - Init

    init(
        projectManifest: Project.Manifest,
        sceneManifest: Scene.Manifest,
        layer: Scene.Layer,
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?
    ) {
        self.layer = layer

        // Generate frame scene graph
        self.frameSceneGraph = FrameSceneGraphBuilder.build(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndex: frameIndex)

        // Resolve active drawing with pre-computed colors/alphas
        self.activeDrawingContext = Self.buildActiveDrawingContext(
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig)

        // Collect all asset IDs
        self.assetIDs = Self.collectAssetIDs(
            frameSceneGraph: frameSceneGraph,
            activeDrawingContext: activeDrawingContext)
    }

    // MARK: - Active Drawing Resolution

    private static func buildActiveDrawingContext(
        layerContent: Scene.AnimationLayerContent,
        frameIndex: Int,
        onionSkinConfig: AnimEditorOnionSkinConfig?
    ) -> ActiveDrawingContext {

        let drawings = layerContent.drawings

        let sortedDrawings = drawings.sorted {
            $0.frameIndex < $1.frameIndex
        }
        let activeDrawingIndex = sortedDrawings.lastIndex {
            $0.frameIndex <= frameIndex
        }

        var activeDrawing: Scene.Drawing?
        var prevOnionSkinDrawings: [ActiveDrawingContext.OnionSkinDrawing] = []
        var nextOnionSkinDrawings: [ActiveDrawingContext.OnionSkinDrawing] = []

        if let activeDrawingIndex, let config = onionSkinConfig {
            activeDrawing = sortedDrawings[activeDrawingIndex]

            // Build previous onion skin layers
            prevOnionSkinDrawings = buildOnionSkinLayers(
                sortedDrawings: sortedDrawings,
                startIndex: activeDrawingIndex,
                count: config.prevCount,
                direction: -1,
                baseColor: config.prevColor,
                alpha: config.alpha,
                alphaFalloff: config.alphaFalloff)

            // Build next onion skin layers
            nextOnionSkinDrawings = buildOnionSkinLayers(
                sortedDrawings: sortedDrawings,
                startIndex: activeDrawingIndex,
                count: config.nextCount,
                direction: 1,
                baseColor: config.nextColor,
                alpha: config.alpha,
                alphaFalloff: config.alphaFalloff)

        } else if let activeDrawingIndex {
            activeDrawing = sortedDrawings[activeDrawingIndex]
        }

        return ActiveDrawingContext(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
    }

    private static func buildOnionSkinLayers(
        sortedDrawings: [Scene.Drawing],
        startIndex: Int,
        count: Int,
        direction: Int,
        baseColor: Color,
        alpha: Double,
        alphaFalloff: Double
    ) -> [ActiveDrawingContext.OnionSkinDrawing] {

        var layers: [ActiveDrawingContext.OnionSkinDrawing] = []
        var index = startIndex

        for offset in 1...count {
            index += direction
            if sortedDrawings.indices.contains(index) {
                let drawing = sortedDrawings[index]
                let layerAlpha = alpha - alphaFalloff * Double(offset)
                let tintColor = baseColor.withAlpha(layerAlpha)

                layers.append(
                    ActiveDrawingContext.OnionSkinDrawing(
                        drawing: drawing,
                        tintColor: tintColor,
                        alpha: layerAlpha))
            }
        }

        return layers
    }

    // MARK: - Asset Collection

    private static func collectAssetIDs(
        frameSceneGraph: FrameSceneGraph,
        activeDrawingContext: ActiveDrawingContext
    ) -> Set<String> {
        var assetIDs = Set<String>()

        // Collect asset IDs from frame scene graph layers
        for layer in frameSceneGraph.layers {
            switch layer.content {
            case .drawing(let content):
                if let assetID = content.drawing.fullAssetID {
                    assetIDs.insert(assetID)
                }
            }
        }

        // Collect asset ID from active drawing
        if let assetID = activeDrawingContext.activeDrawing?.fullAssetID {
            assetIDs.insert(assetID)
        }

        // Collect asset IDs from previous onion skin drawings
        for onionDrawing in activeDrawingContext.prevOnionSkinDrawings {
            if let assetID = onionDrawing.drawing.fullAssetID {
                assetIDs.insert(assetID)
            }
        }

        // Collect asset IDs from next onion skin drawings
        for onionDrawing in activeDrawingContext.nextOnionSkinDrawings {
            if let assetID = onionDrawing.drawing.fullAssetID {
                assetIDs.insert(assetID)
            }
        }

        return assetIDs
    }

}
