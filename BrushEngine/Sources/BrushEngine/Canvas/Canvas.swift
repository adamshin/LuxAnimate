
import Foundation
import Metal
import Color
import Render

extension Canvas {
    
    @MainActor
    public protocol Delegate: AnyObject {
        func onUpdateTexture(_ c: Canvas)
        func onEndBrushStroke(_ c: Canvas)
    }
    
}

@MainActor
public class Canvas {
    
    public weak var delegate: Delegate?
    
    private let renderer: CanvasRenderer
    private let strokeRenderer: StrokeRenderer
    private let textureBlitter: TextureBlitter
    
    private let baseTexture: MTLTexture
    
    private var strokeEngine: StrokeEngine?
    
    // MARK: - Init
    
    public init(
        width: Int,
        height: Int,
        debugRender: Bool,
        brushMode: BrushEngine.BrushMode,
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        let textureCreator = TextureCreator(
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        renderer = CanvasRenderer(
            canvasWidth: width,
            canvasHeight: height,
            brushMode: brushMode,
            pixelFormat: pixelFormat,
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        strokeRenderer = StrokeRenderer(
            canvasWidth: width,
            canvasHeight: height,
            debugRender: debugRender,
            pixelFormat: pixelFormat,
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        textureBlitter = TextureBlitter(
            commandQueue: commandQueue)
        
        baseTexture = try! textureCreator
            .createEmptyTexture(
                width: width,
                height: height,
                pixelFormat: pixelFormat,
                usage: .shaderRead)
    }
    
    // MARK: - Interface
    
    var texture: MTLTexture { renderer.texture }
    
    public func setTextureContents(
        _ newTexture: MTLTexture
    ) {
        endStroke()
        
        try? textureBlitter.blit(
            from: newTexture,
            to: baseTexture)
        
        renderer.draw(
            baseTexture: baseTexture,
            strokeTexture: nil)
    }
    
    public func beginStroke(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        strokeEngine = StrokeEngine(
            brush: brush,
            color: color,
            scale: scale,
            smoothing: smoothing,
            quickTap: quickTap)
    }
    
    public func updateStroke(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) { 
        strokeEngine?.update(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    public func updateStroke(
        sampleUpdates: [InputSampleUpdate]
    ) {
        strokeEngine?.update(
            sampleUpdates: sampleUpdates)
    }
    
    public func endStroke() {
        guard let strokeEngine else { return }
        
        let strokeEngineOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            strokeEngineOutput: strokeEngineOutput)
        
        renderer.draw(
            baseTexture: baseTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        try? textureBlitter.blit(
            from: renderer.texture,
            to: baseTexture,
            waitUntilCompleted: true)
        
        strokeRenderer.clearStroke()
        
        renderer.draw(
            baseTexture: baseTexture,
            strokeTexture: nil)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateTexture(self)
        delegate?.onEndBrushStroke(self)
    }
    
    public func cancelStroke() {
        strokeRenderer.clearStroke()
        
        renderer.draw(
            baseTexture: baseTexture,
            strokeTexture: nil)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateTexture(self)
    }
    
    public func onFrame() {
        guard let strokeEngine else { return }
        
        let strokeEngineOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            strokeEngineOutput: strokeEngineOutput)
        
        renderer.draw(
            baseTexture: baseTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        delegate?.onUpdateTexture(self)
    }
    
}
