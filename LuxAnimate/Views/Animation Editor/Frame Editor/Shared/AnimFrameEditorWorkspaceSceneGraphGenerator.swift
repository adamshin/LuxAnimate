//
//  AnimFrameEditorWorkspaceSceneGraphGenerator.swift
//

import Metal
import Render
import Color

@MainActor
protocol AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate: AnyObject {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphGenerator,
        assetID: String
    ) -> MTLTexture?
    
}

@MainActor
class AnimFrameEditorWorkspaceSceneGraphGenerator {
    
    weak var delegate: AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate?
    
    func generate(
        editContext: AnimFrameEditContext,
        activeDrawingTexture: MTLTexture?
    ) -> EditorWorkspaceSceneGraph {

        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []

        let backgroundLayer = EditorWorkspaceSceneGraph.Layer(
            content: .rect(.init(
                color: editContext.frameSceneGraph.backgroundColor)),
            contentSize: editContext.frameSceneGraph.contentSize,
            transform: .identity,
            alpha: 1)

        outputLayers.append(backgroundLayer)

        for layer in editContext.frameSceneGraph.layers {
            let layerOutputLayers = outputLayersForLayer(
                layer: layer,
                editContext: editContext,
                activeDrawingTexture: activeDrawingTexture)

            outputLayers.append(contentsOf: layerOutputLayers)
        }

        return EditorWorkspaceSceneGraph(
            contentSize: editContext.frameSceneGraph.contentSize,
            layers: outputLayers)
    }
    
    private func outputLayersForLayer(
        layer: FrameSceneGraph.Layer,
        editContext: AnimFrameEditContext,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {

        switch layer.content {
        case .drawing(let drawingLayerContent):
            return outputLayersForDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                editContext: editContext,
                activeDrawingTexture: activeDrawingTexture)
        }
    }
    
    private func outputLayersForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        editContext: AnimFrameEditContext,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {

        if drawingLayerContent.drawing.id == editContext.activeDrawingContext.activeDrawing?.id {
            return outputLayersForActiveDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                editContext: editContext,
                activeDrawingTexture: activeDrawingTexture)

        } else {
            return outputLayersForInactiveDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent)
        }
    }
    
    private func outputLayersForActiveDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        editContext: AnimFrameEditContext,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {

        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []

        // Previous onion skin layers with pre-computed colors
        for onionDrawing in editContext.activeDrawingContext.prevOnionSkinDrawings {
            outputLayers.append(outputLayerForOnionSkinDrawing(
                layer: layer,
                onionDrawing: onionDrawing))
        }

        // Next onion skin layers with pre-computed colors
        for onionDrawing in editContext.activeDrawingContext.nextOnionSkinDrawings {
            outputLayers.append(outputLayerForOnionSkinDrawing(
                layer: layer,
                onionDrawing: onionDrawing))
        }

        // Active drawing
        outputLayers.append(outputLayerForDrawingLayer(
            layer: layer,
            drawing: drawingLayerContent.drawing,
            replacementTexture: activeDrawingTexture))

        return outputLayers
    }
    
    private func outputLayersForInactiveDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        let outputLayer = outputLayerForDrawingLayer(
            layer: layer,
            drawing: drawingLayerContent.drawing)
        
        return [outputLayer]
    }
    
    private func outputLayerForOnionSkinDrawing(
        layer: FrameSceneGraph.Layer,
        onionDrawing: AnimFrameEditContext.ActiveDrawingContext.OnionSkinDrawing
    ) -> EditorWorkspaceSceneGraph.Layer {

        let texture = onionDrawing.drawing.fullAssetID.flatMap {
            delegate?.assetTexture(self, assetID: $0)
        }

        let imageLayerContent = EditorWorkspaceSceneGraph
            .ImageLayerContent(
                texture: texture,
                colorMode: .stencil,
                color: onionDrawing.tintColor)

        return EditorWorkspaceSceneGraph.Layer(
            content: .image(imageLayerContent),
            contentSize: layer.contentSize,
            transform: layer.transform,
            alpha: layer.alpha)
    }

    private func outputLayerForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawing: Scene.Drawing,
        replacementTexture: MTLTexture? = nil
    ) -> EditorWorkspaceSceneGraph.Layer {

        let texture: MTLTexture?
        if let replacementTexture {
            texture = replacementTexture
        } else {
            texture = drawing.fullAssetID.flatMap {
                delegate?.assetTexture(self, assetID: $0)
            }
        }

        let imageLayerContent = EditorWorkspaceSceneGraph
            .ImageLayerContent(
                texture: texture,
                colorMode: .none,
                color: .clear)

        return EditorWorkspaceSceneGraph.Layer(
            content: .image(imageLayerContent),
            contentSize: layer.contentSize,
            transform: layer.transform,
            alpha: layer.alpha)
    }
    
}
