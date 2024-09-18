//
//  AnimFrameEditorWorkspaceSceneGraphGenerator.swift
//

import Metal

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
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> EditorWorkspaceSceneGraph {
        
        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []
        
        let backgroundLayer = EditorWorkspaceSceneGraph.Layer(
            content: .rect(.init(
                color: frameSceneGraph.backgroundColor)),
            contentSize: frameSceneGraph.contentSize,
            transform: .identity,
            alpha: 1)
        
        outputLayers.append(backgroundLayer)
        
        for layer in frameSceneGraph.layers {
            let layerOutputLayers = outputLayersForLayer(
                layer: layer,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture,
                onionSkinConfig: onionSkinConfig)
            
            outputLayers.append(contentsOf: layerOutputLayers)
        }
        
        return EditorWorkspaceSceneGraph(
            contentSize: frameSceneGraph.contentSize,
            layers: outputLayers)
    }
    
    private func outputLayersForLayer(
        layer: FrameSceneGraph.Layer,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        switch layer.content {
        case .drawing(let drawingLayerContent):
            return outputLayersForDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture,
                onionSkinConfig: onionSkinConfig)
        }
    }
    
    private func outputLayersForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        if drawingLayerContent.drawing.id == activeDrawingManifest.activeDrawing?.id {
            return outputLayersForActiveDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture,
                onionSkinConfig: onionSkinConfig)
            
        } else {
            return outputLayersForInactiveDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent)
        }
    }
    
    private func outputLayersForActiveDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?,
        onionSkinConfig: AnimEditorOnionSkinConfig
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []
        
        for (index, drawing) in
            activeDrawingManifest.prevOnionSkinDrawings.enumerated()
        {
            outputLayers.append(outputLayerForDrawingLayer(
                layer: layer,
                drawing: drawing,
                onionSkinConfig: onionSkinConfig,
                onionSkinOffset: -index - 1))
        }
        
        for (index, drawing) in
            activeDrawingManifest.nextOnionSkinDrawings.enumerated()
        {
            outputLayers.append(outputLayerForDrawingLayer(
                layer: layer,
                drawing: drawing,
                onionSkinConfig: onionSkinConfig,
                onionSkinOffset: index + 1))
        }
        
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
    
    private func outputLayerForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawing: Scene.Drawing,
        replacementTexture: MTLTexture? = nil,
        onionSkinConfig: AnimEditorOnionSkinConfig? = nil,
        onionSkinOffset: Int = 0
    ) -> EditorWorkspaceSceneGraph.Layer {
        
        let texture: MTLTexture?
        if let replacementTexture {
            texture = replacementTexture
        } else {
            texture = drawing.fullAssetID.flatMap {
                delegate?.assetTexture(self, assetID: $0)
            }
        }
        
        let colorMode: ColorMode
        let color: Color
        
        if let onionSkinConfig {
            if onionSkinOffset == 0 {
                colorMode = .none
            } else {
                colorMode = .stencil
            }
            if onionSkinOffset == 0 {
                color = .clear
            } else if onionSkinOffset > 0 {
                color = onionSkinConfig.nextColor.withAlpha(
                    onionSkinConfig.alpha -
                    onionSkinConfig.alphaFalloff * Double(abs(onionSkinOffset)))
            } else {
                color = onionSkinConfig.prevColor.withAlpha(
                    onionSkinConfig.alpha -
                    onionSkinConfig.alphaFalloff * Double(abs(onionSkinOffset)))
            }
            
        } else {
            colorMode = .none
            color = .clear
        }
        
        let imageLayerContent = EditorWorkspaceSceneGraph
            .ImageLayerContent(
                texture: texture,
                colorMode: colorMode,
                color: color)
        
        return EditorWorkspaceSceneGraph.Layer(
            content: .image(imageLayerContent),
            contentSize: layer.contentSize,
            transform: layer.transform,
            alpha: layer.alpha)
    }
    
}
