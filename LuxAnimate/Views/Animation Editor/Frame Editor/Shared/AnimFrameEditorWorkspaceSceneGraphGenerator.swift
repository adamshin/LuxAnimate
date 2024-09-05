//
//  AnimFrameEditorWorkspaceSceneGraphGenerator.swift
//

import Metal

private let onionSkinPrevColor = Color(hex: "FF4444")
private let onionSkinNextColor = Color(hex: "22DD55")

private let onionSkinAlpha: Double = 0.6
private let onionSkinAlphaFalloff: Double = 0.2

protocol AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate: AnyObject {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphGenerator,
        assetID: String) -> MTLTexture?
    
}

class AnimFrameEditorWorkspaceSceneGraphGenerator {
    
    weak var delegate: AnimFrameEditorWorkspaceSceneGraphGeneratorDelegate?
    
    func generate(
        frameSceneGraph: FrameSceneGraph,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?
    ) -> EditorWorkspaceSceneGraph {
        
        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []
        
        for layer in frameSceneGraph.layers {
            let layerOutputLayers = outputLayersForLayer(
                layer: layer,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture)
            
            outputLayers.append(contentsOf: layerOutputLayers)
        }
        
        return EditorWorkspaceSceneGraph(
            contentSize: frameSceneGraph.contentSize,
            layers: outputLayers)
    }
    
    private func outputLayersForLayer(
        layer: FrameSceneGraph.Layer,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        switch layer.content {
        case .drawing(let drawingLayerContent):
            return outputLayersForDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                activeDrawingManifest: activeDrawingManifest,
                activeDrawingTexture: activeDrawingTexture)
        }
    }
    
    private func outputLayersForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        if drawingLayerContent.drawing.id == activeDrawingManifest.activeDrawing?.id {
            return outputLayersForActiveDrawingLayer(
                layer: layer,
                drawingLayerContent: drawingLayerContent,
                activeDrawingManifest: activeDrawingManifest,
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
        activeDrawingManifest: AnimFrameEditorHelper.ActiveDrawingManifest,
        activeDrawingTexture: MTLTexture?
    ) -> [EditorWorkspaceSceneGraph.Layer] {
        
        var outputLayers: [EditorWorkspaceSceneGraph.Layer] = []
        
        for (index, drawing) in
            activeDrawingManifest.prevOnionSkinDrawings.enumerated()
        {
            outputLayers.append(outputLayerForDrawingLayer(
                layer: layer,
                drawing: drawing,
                onionSkinOffset: -index - 1))
        }
        
        for (index, drawing) in
            activeDrawingManifest.nextOnionSkinDrawings.enumerated()
        {
            outputLayers.append(outputLayerForDrawingLayer(
                layer: layer,
                drawing: drawing,
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
        onionSkinOffset: Int = 0
    ) -> EditorWorkspaceSceneGraph.Layer {
        
        let texture: MTLTexture?
        if let replacementTexture {
            texture = replacementTexture
        } else {
            let assetID = drawing.assetIDs?.full
            texture = assetID.flatMap {
                delegate?.assetTexture(self, assetID: $0)
            }
        }
        
        let colorMode: ColorMode = if onionSkinOffset == 0 {
            .none
        } else {
            .stencil
        }
        
        let color: Color = if onionSkinOffset == 0 {
            .clear
        } else if onionSkinOffset > 0 {
            onionSkinNextColor.withAlpha(
                onionSkinAlpha - 
                onionSkinAlphaFalloff * Double(abs(onionSkinOffset)))
        } else {
            onionSkinPrevColor.withAlpha(
                onionSkinAlpha -
                onionSkinAlphaFalloff * Double(abs(onionSkinOffset)))
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
