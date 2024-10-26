
import Metal
import Geometry
import Render
import Color

private let paddingSizeThreshold: Double = 20

struct StampRenderer {
    
    private let commandQueue: MTLCommandQueue
    private let debugRender: Bool
    
    private let spriteRenderer: SpriteRenderer
    
    init(
        debugRender: Bool,
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        self.commandQueue = commandQueue
        self.debugRender = debugRender
        
        spriteRenderer = SpriteRenderer(
            pixelFormat: pixelFormat,
            metalDevice: metalDevice)
    }
    
    func drawStamps(
        target: MTLTexture,
        viewportSize: Size,
        stamps: any Sequence<Stamp>,
        brush: Brush,
        finalized: Bool
    ) {
        let sprites = stamps.map { s in
            let offsetPosition =
                s.position + s.offset * s.size
            
            let paddingScale: Double =
                s.size < paddingSizeThreshold ?
                3 : 1
            
            let color: Color
            if !finalized, debugRender {
                color = .debugRed
            } else {
                color = s.color
            }
            
            return SpriteRenderer.Sprite(
                position: offsetPosition,
                size: Size(s.size, s.size),
                rotation: s.rotation,
                color: color,
                alpha: s.alpha,
                paddingScale: paddingScale)
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            texture: brush.stampTexture,
            sprites: sprites,
            blendMode: .normal,
            sampleMode: .linearClampEdgeToBlack,
            colorMode: .brush)
        
        commandBuffer.commit()
    }
    
}
