//
//  EditorWorkspaceRenderer.swift
//

import Metal
import UIKit

private let backgroundColor = Color(UIColor.editorBackground)
private let scalePixelateThreshold: Scalar = 1.0

struct EditorWorkspaceRenderer {
    
    private let spriteRenderer: SpriteRenderer
    private let blankTexture: MTLTexture
    
    init(
        pixelFormat: MTLPixelFormat
    ) {
        spriteRenderer = SpriteRenderer(pixelFormat: pixelFormat)
        blankTexture = createBlankTexture(color: .white)!
    }
    
    func draw(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        // Transform
        let viewportTransform = Matrix3(translation: Vector(
            viewportSize.width / 2,
            viewportSize.height / 2))
        
        let contentTransform =
            viewportTransform *
            workspaceTransform.matrix()
        
        // Pixelation
        let pixelate =
            workspaceTransform.scale >
            scalePixelateThreshold
        
        // Background color
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: target,
            color: backgroundColor)
        
        // Layers
        for layer in sceneGraph.layers {
            switch layer.content {
            case .drawing(let content):
                drawDrawingLayer(
                    target: target,
                    commandBuffer: commandBuffer,
                    viewportSize: viewportSize,
                    contentTransform: contentTransform,
                    layer: layer,
                    content: content,
                    pixelate: pixelate)
                
            case .rect(let content):
                drawRectLayer(
                    target: target,
                    commandBuffer: commandBuffer,
                    viewportSize: viewportSize,
                    contentTransform: contentTransform,
                    layer: layer,
                    content: content)
            }
        }
    }
    
    private func drawDrawingLayer(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        contentTransform: Matrix3,
        layer: EditorWorkspaceSceneGraph.Layer,
        content: EditorWorkspaceSceneGraph.DrawingLayerContent,
        pixelate: Bool
    ) {
        let transform = contentTransform * layer.transform
        
        let sampleMode: SampleMode = pixelate ?
            .nearest : .linear
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: content.texture,
            sprites: [
                .init(
                    position: .zero,
                    size: layer.contentSize,
                    transform: transform,
                    alpha: layer.alpha)
            ],
            sampleMode: sampleMode)
    }
    
    private func drawRectLayer(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        contentTransform: Matrix3,
        layer: EditorWorkspaceSceneGraph.Layer,
        content: EditorWorkspaceSceneGraph.RectLayerContent
    ) { 
        let transform = contentTransform * layer.transform
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: blankTexture,
            sprites: [
                .init(
                    position: .zero,
                    size: layer.contentSize,
                    transform: transform,
                    alpha: layer.alpha)
            ],
            colorMode: .stencil,
            color: content.color)
    }
    
}

private func createBlankTexture(color: Color) -> MTLTexture? {
    let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: .rgba8Unorm,
        width: 1,
        height: 1,
        mipmapped: false)
    textureDescriptor.usage = [.shaderRead, .shaderWrite]
    
    guard let texture = MetalInterface.shared.device
        .makeTexture(descriptor: textureDescriptor)
    else { return nil }
    
    let region = MTLRegionMake2D(0, 0, 1, 1)
    var c = simd_uchar4(color.r, color.g, color.b, color.a)
    
    texture.replace(region: region, mipmapLevel: 0, withBytes: &c, bytesPerRow: 4)
    
    return texture
}
