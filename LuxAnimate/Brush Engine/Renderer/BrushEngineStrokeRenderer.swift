//
//  BrushEngineStrokeRenderer.swift
//

import Metal

class BrushEngineStrokeRenderer {
    
    private let canvasSize: PixelSize
    private let stampRenderer = BrushEngineStampRenderer()
    
    let partialStrokeTexture: MTLTexture
    let fullStrokeTexture: MTLTexture
    
    private var drawnFinalizedStampCount = 0
    
    // MARK: - Init
    
    init(canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = canvasSize.width
        texDesc.height = canvasSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = [.renderTarget, .shaderRead]
        
        partialStrokeTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        fullStrokeTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        clearStroke()
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
    
    func clearStroke() {
        drawnFinalizedStampCount = 0
        
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: partialStrokeTexture,
            color: .clear)
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: fullStrokeTexture,
            color: .clear)
        
        commandBuffer.commit()
    }
    
    func drawIncrementalStroke(
        stroke: BrushStrokeEngine.OutputStroke
    ) {
        let viewportSize = Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
        
        let finalizedStampCount = Self.finalizedStampCount(
            for: stroke,
            startingAt: drawnFinalizedStampCount)
        
        stampRenderer.drawStamps(
            target: partialStrokeTexture,
            viewportSize: viewportSize,
            stamps: stroke.stamps,
            startIndex: drawnFinalizedStampCount,
            endIndex: finalizedStampCount,
            brush: stroke.brush,
            color: stroke.color)
        
        try? TextureBlitter.blit(
            from: partialStrokeTexture,
            to: fullStrokeTexture)
        
        stampRenderer.drawStamps(
            target: fullStrokeTexture,
            viewportSize: viewportSize,
            stamps: stroke.stamps,
            startIndex: finalizedStampCount,
            endIndex: stroke.stamps.count,
            brush: stroke.brush,
            color: AppConfig.brushRenderDebug ? 
                Color.debugRed : stroke.color)
        
        drawnFinalizedStampCount = finalizedStampCount
    }
    
}
