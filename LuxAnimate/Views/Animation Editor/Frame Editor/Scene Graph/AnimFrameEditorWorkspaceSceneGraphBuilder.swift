//
//  AnimFrameEditorWorkspaceSceneGraphBuilder.swift
//

import Metal
import Render
import Color

@MainActor
protocol AnimFrameEditorWorkspaceSceneGraphBuilderDelegate:
    AnyObject {
    
    func assetTexture(
        _ g: AnimFrameEditorWorkspaceSceneGraphBuilder,
        assetID: String
    ) -> MTLTexture?
    
}

@MainActor
class AnimFrameEditorWorkspaceSceneGraphBuilder {
    
    weak var delegate:
        AnimFrameEditorWorkspaceSceneGraphBuilderDelegate?
    
    func build(
        sceneGraph: AnimFrameEditorSceneGraph,
        activeDrawingTexture: MTLTexture?
    ) -> EditorWorkspaceSceneGraph {
        
        let contentSize = sceneGraph
            .frameSceneGraph.contentSize
        
        var layers: [EditorWorkspaceSceneGraph.Layer] = []
        
        buildBackgroundLayer(
            sceneGraph: sceneGraph,
            output: &layers)
        
        buildContentLayers(
            sceneGraph: sceneGraph,
            activeDrawingTexture: activeDrawingTexture,
            output: &layers)
        
        return EditorWorkspaceSceneGraph(
            contentSize: contentSize,
            layers: layers)
    }
    
    private func buildBackgroundLayer(
        sceneGraph: AnimFrameEditorSceneGraph,
        output: inout [EditorWorkspaceSceneGraph.Layer]
    ) {
        let color = sceneGraph
            .frameSceneGraph.backgroundColor
        let contentSize = sceneGraph
            .frameSceneGraph.contentSize
        
        let l = EditorWorkspaceSceneGraph.Layer(
            content: .rect(.init(color: color)),
            contentSize: contentSize,
            transform: .identity,
            alpha: 1)
        
        output.append(l)
    }
    
    private func buildContentLayers(
        sceneGraph: AnimFrameEditorSceneGraph,
        activeDrawingTexture: MTLTexture?,
        output: inout [EditorWorkspaceSceneGraph.Layer]
    ) {
        for layer in sceneGraph.frameSceneGraph.layers {
            switch layer.content {
            case .drawing(let drawingLayerContent):
                buildLayersForDrawingLayer(
                    layer: layer,
                    drawingLayerContent: drawingLayerContent,
                    sceneGraph: sceneGraph,
                    activeDrawingTexture: activeDrawingTexture,
                    output: &output)
            }
        }
    }
    
    private func buildLayersForDrawingLayer(
        layer: FrameSceneGraph.Layer,
        drawingLayerContent: FrameSceneGraph.DrawingLayerContent,
        sceneGraph: AnimFrameEditorSceneGraph,
        activeDrawingTexture: MTLTexture?,
        output: inout [EditorWorkspaceSceneGraph.Layer]
    ) {
        let isActiveDrawing =
            drawingLayerContent.drawing.id ==
            sceneGraph.activeDrawingContext.activeDrawing?.id
        
        if isActiveDrawing {
            buildLayersForActiveDrawing(
                layer: layer,
                drawing: drawingLayerContent.drawing,
                sceneGraph: sceneGraph,
                activeDrawingTexture: activeDrawingTexture,
                output: &output)
        } else {
            buildLayerForDrawing(
                layer: layer,
                drawing: drawingLayerContent.drawing,
                output: &output)
        }
    }
    
    private func buildLayersForActiveDrawing(
        layer: FrameSceneGraph.Layer,
        drawing: Scene.Drawing,
        sceneGraph: AnimFrameEditorSceneGraph,
        activeDrawingTexture: MTLTexture?,
        output: inout [EditorWorkspaceSceneGraph.Layer]
    ) {
        for drawing in sceneGraph
            .activeDrawingContext.onionSkinDrawings
        {
            buildLayerForDrawing(
                layer: layer,
                drawing: drawing.drawing,
                colorMode: .stencil,
                color: drawing.tintColor,
                output: &output)
        }
        
        buildLayerForDrawing(
            layer: layer,
            drawing: drawing,
            overrideTexture: activeDrawingTexture,
            output: &output)
    }
    
    private func buildLayerForDrawing(
        layer: FrameSceneGraph.Layer,
        drawing: Scene.Drawing,
        overrideTexture: MTLTexture? = nil,
        colorMode: ColorMode = .none,
        color: Color = .clear,
        output: inout [EditorWorkspaceSceneGraph.Layer]
    ) {
        let texture: MTLTexture?
        if let overrideTexture {
            texture = overrideTexture
        } else if let assetID = drawing.fullAssetID {
            texture = delegate?
                .assetTexture(self, assetID: assetID)
        } else {
            texture = nil
        }
        
        let o = EditorWorkspaceSceneGraph.Layer(
            content: .image(.init(
                texture: texture,
                colorMode: colorMode,
                color: color)),
            contentSize: layer.contentSize,
            transform: layer.transform,
            alpha: layer.alpha)
        
        output.append(o)
    }
    
}
