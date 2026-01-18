//
//  AnimFrameEditContext.swift
//

import Foundation
import Color

/// Everything needed to draw and edit a specific frame.
///
/// This context represents all the data required to render a frame in the animation editor,
/// including the frame's scene graph structure, which drawings to show (including onion skin layers
/// with pre-computed colors and alphas), and which assets need to be loaded.
struct AnimFrameEditContext {

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
        // Generate frame scene graph
        self.frameSceneGraph = FrameSceneGraphGenerator.generate(
            projectManifest: projectManifest,
            sceneManifest: sceneManifest,
            frameIndex: frameIndex)

        // Resolve active drawing with pre-computed colors/alphas
        self.activeDrawingContext = Self.resolveActiveDrawing(
            layerContent: layerContent,
            frameIndex: frameIndex,
            onionSkinConfig: onionSkinConfig)

        // Collect all asset IDs
        self.assetIDs = Self.collectAssetIDs(
            frameSceneGraph: frameSceneGraph,
            activeDrawingContext: activeDrawingContext)
    }

    // MARK: - Active Drawing Resolution

    private static func resolveActiveDrawing(
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

        if let activeDrawingIndex {
            activeDrawing = sortedDrawings[activeDrawingIndex]

            if let config = onionSkinConfig {
                // Build previous onion skin layers with pre-computed colors/alphas
                var prevDrawingIndex = activeDrawingIndex
                for offset in 1...config.prevCount {
                    prevDrawingIndex -= 1
                    if sortedDrawings.indices.contains(prevDrawingIndex) {
                        let drawing = sortedDrawings[prevDrawingIndex]
                        let alpha = config.alpha - config.alphaFalloff * Double(offset)
                        let tintColor = config.prevColor.withAlpha(alpha)

                        prevOnionSkinDrawings.append(
                            ActiveDrawingContext.OnionSkinDrawing(
                                drawing: drawing,
                                tintColor: tintColor,
                                alpha: alpha))
                    }
                }

                // Build next onion skin layers with pre-computed colors/alphas
                var nextDrawingIndex = activeDrawingIndex
                for offset in 1...config.nextCount {
                    nextDrawingIndex += 1
                    if sortedDrawings.indices.contains(nextDrawingIndex) {
                        let drawing = sortedDrawings[nextDrawingIndex]
                        let alpha = config.alpha - config.alphaFalloff * Double(offset)
                        let tintColor = config.nextColor.withAlpha(alpha)

                        nextOnionSkinDrawings.append(
                            ActiveDrawingContext.OnionSkinDrawing(
                                drawing: drawing,
                                tintColor: tintColor,
                                alpha: alpha))
                    }
                }
            }
        }

        return ActiveDrawingContext(
            activeDrawing: activeDrawing,
            prevOnionSkinDrawings: prevOnionSkinDrawings,
            nextOnionSkinDrawings: nextOnionSkinDrawings)
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
