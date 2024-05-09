//
//  BrushEngineRenderer.swift
//

import Metal

class BrushEngineRenderer {
    
    private let canvasSize: PixelSize
    
    private let stampRenderer = BrushEngineStampRenderer()
    private let textureBlitter = TextureBlitter()
    
    private let originalCanvasTexture: MTLTexture
    private let partialStrokeCanvasTexture: MTLTexture
    private let fullStrokeCanvasTexture: MTLTexture
    
    private var drawnFinalizedStampCount = 0
    
    init(canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        let texDesc = MTLTextureDescriptor()
        texDesc.width = canvasSize.width
        texDesc.height = canvasSize.height
        texDesc.pixelFormat = AppConfig.pixelFormat
        texDesc.storageMode = .shared
        texDesc.usage = [.renderTarget, .shaderRead]
        
        originalCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        partialStrokeCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
        
        fullStrokeCanvasTexture = MetalInterface.shared
            .device.makeTexture(descriptor: texDesc)!
    }
    
    var canvasTexture: MTLTexture {
        fullStrokeCanvasTexture
    }
    
    func setCanvasContents(_ texture: MTLTexture) {
        do {
            try textureBlitter.blit(
                from: texture,
                to: originalCanvasTexture)
            
            try textureBlitter.blit(
                from: texture,
                to: partialStrokeCanvasTexture)
            
            try textureBlitter.blit(
                from: texture,
                to: fullStrokeCanvasTexture)
            
        } catch { }
    }
    
    func update(
        stroke: BrushStrokeEngine.OutputStroke,
        brushMode: BrushEngine.BrushMode
    ) {
        let erase = switch brushMode {
        case .brush: false
        case .erase: true
        }
        
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
            color: stroke.color,
            erase: erase)
        
        try? textureBlitter.blit(
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
                Color.debugRed : stroke.color,
            erase: erase)
        
        drawnFinalizedStampCount = finalizedStampCount
    }
    
    func finalizeStroke() {
        drawnFinalizedStampCount = 0
        
        try? textureBlitter.blit(
            from: fullStrokeCanvasTexture,
            to: originalCanvasTexture)
        
        try? textureBlitter.blit(
            from: fullStrokeCanvasTexture,
            to: partialStrokeCanvasTexture)
    }
    
    func cancelStroke() {
        drawnFinalizedStampCount = 0
        
        try? textureBlitter.blit(
            from: originalCanvasTexture,
            to: fullStrokeCanvasTexture)
        
        try? textureBlitter.blit(
            from: originalCanvasTexture,
            to: partialStrokeCanvasTexture)
    }
    
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
    
}
