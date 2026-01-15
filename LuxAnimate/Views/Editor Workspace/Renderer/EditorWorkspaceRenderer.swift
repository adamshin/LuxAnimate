//
//  EditorWorkspaceRenderer.swift
//

import Metal
import UIKit
import Geometry
import Color
import Render

// MARK: - Config

private let backgroundColor = Color(
    UIColor.editorBackground)

private let scalePixelateThreshold: Double = 1.0

// MARK: - EditorWorkspaceRenderer

struct EditorWorkspaceRenderer {
    
    private let spriteRenderer: SpriteRenderer
    private let blankTexture: MTLTexture
    
    // MARK: - Init
    
    init(
        pixelFormat: MTLPixelFormat =
            AppConfig.metalLayerPixelFormat
    ) {
        spriteRenderer = SpriteRenderer(
            pixelFormat: pixelFormat,
            metalDevice: MetalInterface.shared.device)
        
        blankTexture = createBlankTexture(color: .white)!
    }
    
    // MARK: - Draw
    
    func draw(
        drawable: CAMetalDrawable,
        viewportSize: Size,
        workspaceTransform: EditorWorkspaceTransform,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        let target = drawable.texture
        
        let viewportTransform = Matrix3(
            translation: Vector(
                viewportSize.width / 2,
                viewportSize.height / 2))
        
        let contentTransform =
            viewportTransform *
            workspaceTransform.matrix()
        
        let pixelate =
            workspaceTransform.scale >
            scalePixelateThreshold
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        drawSceneGraph(
            target: target,
            commandBuffer: commandBuffer,
            viewportSize: viewportSize,
            contentTransform: contentTransform,
            pixelate: pixelate,
            sceneGraph: sceneGraph)
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func drawSceneGraph(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        contentTransform: Matrix3,
        pixelate: Bool,
        sceneGraph: EditorWorkspaceSceneGraph
    ) {
        // Background color
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: target,
            color: backgroundColor)
        
        // Layers
        for layer in sceneGraph.layers {
            drawLayer(
                target: target,
                commandBuffer: commandBuffer,
                viewportSize: viewportSize,
                contentTransform: contentTransform,
                pixelate: pixelate,
                layer: layer)
        }
    }
    
    private func drawLayer(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        contentTransform: Matrix3,
        pixelate: Bool,
        layer: EditorWorkspaceSceneGraph.Layer
    ) {
        switch layer.content {
        case .image(let content):
            drawImageLayer(
                target: target,
                commandBuffer: commandBuffer,
                viewportSize: viewportSize,
                contentTransform: contentTransform,
                pixelate: pixelate,
                layer: layer,
                content: content)
            
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
    
    private func drawImageLayer(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        contentTransform: Matrix3,
        pixelate: Bool,
        layer: EditorWorkspaceSceneGraph.Layer,
        content: EditorWorkspaceSceneGraph.ImageLayerContent
    ) {
        guard let texture = content.texture else { return }
        
        let transform = contentTransform * layer.transform
        
        let sampleMode: SampleMode = pixelate ?
            .nearest : .linear
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: texture,
            sprites: [
                .init(
                    position: .zero,
                    size: layer.contentSize,
                    transform: transform,
                    color: content.color,
                    alpha: layer.alpha)
            ],
            sampleMode: sampleMode,
            colorMode: content.colorMode)
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
                    color: content.color,
                    alpha: layer.alpha)
            ],
            colorMode: .stencil)
    }
    
}

// MARK: - Utilities

private func createBlankTexture(
    color: Color
) -> MTLTexture? {
    
    let textureDescriptor =
        MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 1,
            height: 1,
            mipmapped: false)
    
    textureDescriptor.usage = [
        .shaderRead,
        .shaderWrite
    ]
    
    guard let texture = MetalInterface.shared.device
        .makeTexture(descriptor: textureDescriptor)
    else { return nil }
    
    let region = MTLRegionMake2D(0, 0, 1, 1)
    
    var c = simd_uchar4(
        color.r,
        color.g,
        color.b,
        color.a)
    
    texture.replace(
        region: region,
        mipmapLevel: 0,
        withBytes: &c,
        bytesPerRow: 4)
    
    return texture
}
