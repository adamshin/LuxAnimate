//
//  TestRenderer.swift
//

import Metal

private let rectSize = Size(1920, 1080)

struct TestRenderer {
    
    private let spriteRenderer: SpriteRenderer
    private let texture: MTLTexture

    init(
        pixelFormat: MTLPixelFormat
    ) {
        spriteRenderer = SpriteRenderer(
            pixelFormat: pixelFormat)
        
        texture = createDefaultTexture(
            color: MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1))!
    }
    
    func draw(
        commandBuffer: MTLCommandBuffer,
        target: MTLTexture
    ) {
        // Clear color
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: target,
            color: .brushBlack)
        
        // Rectangle
        let viewportSize = Size(
            Double(target.width),
            Double(target.height))
        
        let center = Vector(
            viewportSize.width / 2,
            viewportSize.height / 2)
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: texture,
            sprites: [
                .init(
                    position: center,
                    size: rectSize)
            ],
            colorMode: .stencil,
            color: .white)
    }
    
}

private func createDefaultTexture(color: MTLClearColor) -> MTLTexture? {
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
    var c = simd_uchar4(
        UInt8(color.red * 255),
        UInt8(color.green * 255),
        UInt8(color.blue * 255),
        UInt8(color.alpha * 255))
    
    texture.replace(region: region, mipmapLevel: 0, withBytes: &c, bytesPerRow: 4)
    
    return texture
}
