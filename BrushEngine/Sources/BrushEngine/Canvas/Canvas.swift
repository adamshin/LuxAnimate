
import Foundation
import Metal
import Color
import Render

extension Canvas {
    
    @MainActor
    public protocol Delegate: AnyObject {
        func onUpdateTexture(_ c: Canvas)
        func onBrushStroke(_ c: Canvas)
    }
    
}

@MainActor
class Canvas {
    
    weak var delegate: Delegate?
    
    private let baseTexture: MTLTexture
    
    // Renderer
    // Stroke renderer?
    
    // Stroke engine
    
    // Texture blitter
    
    // MARK: - Init
    
    init(
        width: Int,
        height: Int,
        brushMode: BrushEngine.BrushMode,
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        let textureCreator = TextureCreator(
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        baseTexture = try! textureCreator
            .createEmptyTexture(
                width: width,
                height: height,
                pixelFormat: pixelFormat,
                usage: .shaderRead)
    }
    
    // MARK: - Interface
    
//    var texture: MTLTexture { }
    
    func setTextureContents(
        _ newTexture: MTLTexture
    ) {
        // TODO
    }
    
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
        /*
        guard let strokeEngine else { return }
        
        let strokeProcessOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            strokeProcessOutput: strokeProcessOutput)
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        try? textureBlitter.blit(
            from: renderer.renderTarget,
            to: baseCanvasTexture,
            waitUntilCompleted: true)
        
        strokeRenderer.clearStroke()
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: nil)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvasTexture(self)
        
        delegate?.onFinalizeStroke(self,
            canvasTexture: baseCanvasTexture)
         */
    }
    
    func cancelStroke() {
        /*
        strokeRenderer.clearStroke()
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: nil)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvasTexture(self)
         */
    }
    
    func onFrame() {
        /*
        guard let strokeEngine else { return }
        
        let strokeProcessOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            strokeProcessOutput: strokeProcessOutput)
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        delegate?.onUpdateCanvasTexture(self)
         */
    }
    
}
