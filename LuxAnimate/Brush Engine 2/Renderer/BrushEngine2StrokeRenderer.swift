//
//  BrushEngine2StrokeRenderer.swift
//

import Metal

class BrushEngine2StrokeRenderer {
    
    private let canvasSize: PixelSize
    
    private let stampRenderer = BrushEngine2StampRenderer()
    
    let finalizedStrokeTexture: MTLTexture
    let fullStrokeTexture: MTLTexture
    
    // MARK: - Init
    
    init(canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = canvasSize.width
        texDesc.height = canvasSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = [.renderTarget, .shaderRead]
        
        finalizedStrokeTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        fullStrokeTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        clearStroke()
    }
    
    // MARK: - Interface
    
    func clearStroke() {
        let commandBuffer = MetalInterface.shared
            .commandQueue.makeCommandBuffer()!
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: finalizedStrokeTexture,
            color: .clear)
        
        ClearColorRenderer.drawClearColor(
            commandBuffer: commandBuffer,
            target: fullStrokeTexture,
            color: .clear)
        
        commandBuffer.commit()
    }
    
    func drawIncrementalStroke(
        brush: Brush,
        stamps: [BrushEngine2.Stamp]
    ) {
        print("Drawing \(stamps.count) stamps")
        
        let finalizedPrefixCount = stamps
            .prefix { $0.isFinalized }
            .count
        
        let finalizedStamps = stamps[
            0 ..< finalizedPrefixCount
        ]
        
        let nonFinalizedStamps = stamps[
            finalizedPrefixCount ..< stamps.count
        ].map {
            var s = $0
            if AppConfig.brushRenderDebug {
                s.color = Color.debugRed
            }
            return s
        }
        
        let viewportSize = Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
        
        stampRenderer.drawStamps(
            target: finalizedStrokeTexture,
            viewportSize: viewportSize,
            stamps: finalizedStamps,
            brush: brush)
        
        try? TextureBlitter.blit(
            from: finalizedStrokeTexture,
            to: fullStrokeTexture)
        
        stampRenderer.drawStamps(
            target: fullStrokeTexture,
            viewportSize: viewportSize,
            stamps: nonFinalizedStamps,
            brush: brush)
    }
    
}
