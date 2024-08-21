//
//  TestWorkspaceRenderer.swift
//

import Metal
import UIKit

private let clearColor = Color(UIColor.editorBackground)

struct TestWorkspaceRenderer {
    
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
        workspaceTransform: Matrix3,
        scene: TestScene
    ) {
        // Clear color
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: target,
            color: clearColor)
        
        // Layers
        for layer in scene.layers {
            switch layer.content {
            case .rect(let content):
                drawRectLayer(
                    target: target,
                    commandBuffer: commandBuffer,
                    viewportSize: viewportSize,
                    workspaceTransform: workspaceTransform,
                    layer: layer,
                    content: content)
            }
        }
    }
    
    private func drawRectLayer(
        target: MTLTexture,
        commandBuffer: MTLCommandBuffer,
        viewportSize: Size,
        workspaceTransform: Matrix3,
        layer: TestScene.Layer,
        content: TestScene.RectLayerContent
    ) { 
        let center = Vector(
            viewportSize.width / 2,
            viewportSize.height / 2)
        
        let transform = workspaceTransform * layer.transform
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: blankTexture,
            sprites: [
                .init(
                    position: center,
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
