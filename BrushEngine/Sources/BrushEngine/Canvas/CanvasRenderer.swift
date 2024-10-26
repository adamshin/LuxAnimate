
import Foundation
import Metal
import Geometry
import Render

class CanvasRenderer {
    
    private let commandQueue: MTLCommandQueue
    private let strokeBlendMode: BlendMode
    
    private let textureBlitter: TextureBlitter
    private let spriteRenderer: SpriteRenderer
    
    let renderTarget: MTLTexture
    
    init(
        canvasWidth: Int,
        canvasHeight: Int,
        brushMode: BrushMode,
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        self.commandQueue = commandQueue
        
        strokeBlendMode = switch brushMode {
        case .paint: .normal
        case .erase: .erase
        }
        
        textureBlitter = TextureBlitter(
            commandQueue: commandQueue)
        
        spriteRenderer = SpriteRenderer(
            pixelFormat: pixelFormat,
            metalDevice: metalDevice)
        
        let textureCreator = TextureCreator(
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        renderTarget = try! textureCreator
            .createEmptyTexture(
                width: canvasWidth,
                height: canvasHeight,
                pixelFormat: pixelFormat,
                usage: [.renderTarget, .shaderRead])
    }
    
    func draw(
        baseTexture: MTLTexture,
        strokeTexture: MTLTexture?
    ) {
        try? textureBlitter.blit(
            from: baseTexture,
            to: renderTarget)
        
        let commandBuffer = commandQueue
            .makeCommandBuffer()!
        
        if let strokeTexture {
            spriteRenderer.drawSprites(
                commandBuffer: commandBuffer,
                target: renderTarget,
                viewportSize: Size(1, 1),
                texture: strokeTexture,
                sprites: [
                    .init(
                        position: Vector(0.5, 0.5),
                        size: Size(1, 1))
                ],
                blendMode: strokeBlendMode,
                sampleMode: .nearest)
        }
        
        commandBuffer.commit()
    }
    
}
