//
//  BrushEngineStrokeRenderer.swift
//

import Metal
import Geometry
import Render

class BrushEngineStrokeRenderer {
    
    private let canvasSize: PixelSize
    
    private let textureBlitter = TextureBlitter(
        commandQueue: MetalInterface.shared.commandQueue)
    
    private let stampRenderer = BrushEngineStampRenderer()
    
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
        strokeProcessOutput s: BrushStrokeEngine.ProcessOutput
    ) {
//        let totalStampCount =
//            s.finalizedStamps.count +
//            s.nonFinalizedStamps.count
//        print("Drawing \(totalStampCount) stamps")
        
        let viewportSize = Size(
            Scalar(canvasSize.width),
            Scalar(canvasSize.height))
        
        stampRenderer.drawStamps(
            target: finalizedStrokeTexture,
            viewportSize: viewportSize,
            stamps: s.finalizedStamps,
            brush: s.brush,
            finalized: true)
        
        try? textureBlitter.blit(
            from: finalizedStrokeTexture,
            to: fullStrokeTexture)
        
        stampRenderer.drawStamps(
            target: fullStrokeTexture,
            viewportSize: viewportSize,
            stamps: s.nonFinalizedStamps,
            brush: s.brush,
            finalized: false)
    }
    
}
