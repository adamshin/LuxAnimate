
import Foundation
import Metal

public extension Canvas {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onUpdateCanvasTexture(
            _ c: Canvas)
        
        func onFinalizeStroke(
            _ c: Canvas,
            canvasTexture: MTLTexture)
        
    }
    
}

@MainActor
public class Canvas {
    
    public weak var delegate: Delegate?
    
//    private let baseCanvasTexture: MTLTexture
    
//    private let renderer: CanvasRenderer
//    private let strokeRenderer: CanvasStrokeRenderer // TODO: move to stroke engine?
    
//    private var strokeEngine: StrokeEngine?
    
    // MARK: - Initializer
    
//    init(
//        canvasSize: PixelSize,
//        brushMode: BrushMode
//    ) {
//        baseCanvasTexture = try! TextureCreator
//            .createEmptyTexture(
//                size: canvasSize,
//                mipMapped: false)
//        
//        renderer = BrushEngineRenderer(
//            canvasSize: canvasSize,
//            brushMode: brushMode)
//        
//        strokeRenderer = BrushEngineStrokeRenderer(
//            canvasSize: canvasSize)
//    }
    
    // MARK: - Interface
    
//    var canvasTexture: MTLTexture {
//        renderer.renderTarget
//    }
    
//    func setCanvasTextureContents(_ texture: MTLTexture) {
//        endStroke()
//        
//        try? TextureBlitter.blit(
//            from: texture,
//            to: baseCanvasTexture)
//        
//        renderer.draw(
//            baseCanvasTexture: baseCanvasTexture,
//            strokeTexture: nil)
//    }
    
    func beginStroke(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
//        strokeEngine = .init(
//            brush: brush,
//            color: color,
//            scale: scale,
//            smoothing: smoothing,
//            quickTap: quickTap)
    }
    
    func updateStroke(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) { 
//        strokeEngine?.update(
//            addedSamples: addedSamples,
//            predictedSamples: predictedSamples)
    }
    
    func updateStroke(
        sampleUpdates: [InputSampleUpdate]
    ) {
//        strokeEngine?.update(
//            sampleUpdates: sampleUpdates)
    }
    
    func endStroke() {
//        guard let strokeEngine else { return }
//        
//        let strokeProcessOutput = strokeEngine.process()
//        
//        strokeRenderer.drawIncrementalStroke(
//            strokeProcessOutput: strokeProcessOutput)
//        
//        renderer.draw(
//            baseCanvasTexture: baseCanvasTexture,
//            strokeTexture: strokeRenderer.fullStrokeTexture)
//        
//        try? TextureBlitter.blit(
//            from: renderer.renderTarget,
//            to: baseCanvasTexture,
//            waitUntilCompleted: true)
//        
//        strokeRenderer.clearStroke()
//        
//        renderer.draw(
//            baseCanvasTexture: baseCanvasTexture,
//            strokeTexture: nil)
//        
//        self.strokeEngine = nil
//        
//        delegate?.onUpdateCanvasTexture(self)
//        
//        delegate?.onFinalizeStroke(self,
//            canvasTexture: baseCanvasTexture)
    }
    
    func cancelStroke() {
//        strokeRenderer.clearStroke()
//        
//        renderer.draw(
//            baseCanvasTexture: baseCanvasTexture,
//            strokeTexture: nil)
//        
//        self.strokeEngine = nil
//        
//        delegate?.onUpdateCanvasTexture(self)
    }
    
    func onFrame() {
//        guard let strokeEngine else { return }
//        
//        let strokeProcessOutput = strokeEngine.process()
//        
//        strokeRenderer.drawIncrementalStroke(
//            strokeProcessOutput: strokeProcessOutput)
//        
//        renderer.draw(
//            baseCanvasTexture: baseCanvasTexture,
//            strokeTexture: strokeRenderer.fullStrokeTexture)
//        
//        delegate?.onUpdateCanvasTexture(self)
    }
    
}
