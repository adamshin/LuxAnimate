//
//  BrushEngineRenderer.swift
//

import Metal

class BrushEngineRenderer {
    
    private let canvasSize: PixelSize
    private let erase: Bool
    
    private let stampRenderer = BrushEngineStampRenderer()
    private let spriteRenderer = SpriteRenderer()
    
    let renderTarget: MTLTexture
    
    private let baseCanvasTexture: MTLTexture
    private let partialStrokeCanvasTexture: MTLTexture
    private let fullStrokeCanvasTexture: MTLTexture
    
    private var drawnFinalizedStampCount = 0
    
    // MARK: - Init
    
    init(canvasSize: PixelSize, erase: Bool) {
        self.canvasSize = canvasSize
        self.erase = erase
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = canvasSize.width
        texDesc.height = canvasSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = [.renderTarget, .shaderRead]
        
        renderTarget = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        baseCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        partialStrokeCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        fullStrokeCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
    }
    
    // MARK: - Helpers
    
    private static func finalizedStampCount(
        for stroke: BrushStrokeEngine.OutputStroke,
        startingAt startCount: Int
    ) -> Int {
        var count = startCount
        while count < stroke.stamps.count {
            if stroke.stamps[count].isFinalized {
                count += 1
            } else {
                break
            }
        }
        return count
    }
    
    // MARK: - Interface
    
    // This should be combined with the begin stroke function?
    func setBaseCanvasTexture(_ texture: MTLTexture) {
        do {
            try TextureBlitter.blit(
                from: texture,
                to: baseCanvasTexture)
        } catch { }
    }
    
    func beginStroke() {
        drawnFinalizedStampCount = 0
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: partialStrokeCanvasTexture,
            color: .clear)
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: fullStrokeCanvasTexture,
            color: .clear)
        
        commandBuffer.commit()
    }
    
    func update(
        stroke: BrushStrokeEngine.OutputStroke,
        brushMode: BrushEngine.BrushMode
    ) { 
        // Draw stroke
        let viewportSize = Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
        
        let finalizedStampCount = Self.finalizedStampCount(
            for: stroke,
            startingAt: drawnFinalizedStampCount)
        
        stampRenderer.drawStamps(
            target: partialStrokeCanvasTexture,
            viewportSize: viewportSize,
            stamps: stroke.stamps,
            startIndex: drawnFinalizedStampCount,
            endIndex: finalizedStampCount,
            brush: stroke.brush,
            color: stroke.color)
        
        try? TextureBlitter.blit(
            from: partialStrokeCanvasTexture,
            to: fullStrokeCanvasTexture)
        
        stampRenderer.drawStamps(
            target: fullStrokeCanvasTexture,
            viewportSize: viewportSize,
            stamps: stroke.stamps,
            startIndex: finalizedStampCount,
            endIndex: stroke.stamps.count,
            brush: stroke.brush,
            color: AppConfig.brushRenderDebug ? 
                Color.debugRed : stroke.color)
        
        drawnFinalizedStampCount = finalizedStampCount
        
        // Draw to render target
        try? TextureBlitter.blit(
            from: baseCanvasTexture,
            to: renderTarget)
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        spriteRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: renderTarget,
            viewportSize: Size(1, 1),
            texture: fullStrokeCanvasTexture,
            sprites: [
                SpriteRenderer.Sprite(
                    size: Size(1, 1),
                    position: Vector(0.5, 0.5))
            ],
            blendMode: erase ? .normal : .erase,
            sampleMode: .nearest)
        
        commandBuffer.commit()
    }
    
    func finalizeStroke() {
        drawnFinalizedStampCount = 0
        
        try? TextureBlitter.blit(
            from: renderTarget,
            to: baseCanvasTexture)
    }
    
    func cancelStroke() {
        drawnFinalizedStampCount = 0
        
        try? TextureBlitter.blit(
            from: baseCanvasTexture,
            to: renderTarget)
    }
    
}
