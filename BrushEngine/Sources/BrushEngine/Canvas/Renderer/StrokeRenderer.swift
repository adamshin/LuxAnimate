
import Metal
import Geometry
import Render

class StrokeRenderer {
    
    private let canvasWidth: Int
    private let canvasHeight: Int
    private let commandQueue: MTLCommandQueue
    
    private let stampRenderer: StampRenderer
    private let textureBlitter: TextureBlitter
    
    let finalizedStrokeTexture: MTLTexture
    let fullStrokeTexture: MTLTexture
    
    // MARK: - Init
    
    init(
        canvasWidth: Int,
        canvasHeight: Int,
        debugRender: Bool,
        pixelFormat: MTLPixelFormat,
        metalDevice: MTLDevice,
        commandQueue: MTLCommandQueue
    ) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.commandQueue = commandQueue
        
        stampRenderer = StampRenderer(
            debugRender: debugRender,
            pixelFormat: pixelFormat,
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        textureBlitter = TextureBlitter(
            commandQueue: commandQueue)
        
        let textureCreator = TextureCreator(
            metalDevice: metalDevice,
            commandQueue: commandQueue)
        
        finalizedStrokeTexture = try! textureCreator
            .createEmptyTexture(
                width: canvasWidth,
                height: canvasHeight,
                pixelFormat: pixelFormat,
                usage: [.renderTarget, .shaderRead])
        
        fullStrokeTexture = try! textureCreator
            .createEmptyTexture(
                width: canvasWidth,
                height: canvasHeight,
                pixelFormat: pixelFormat,
                usage: [.renderTarget, .shaderRead])

    }
    
    // MARK: - Interface
    
    func clearStroke() {
        let commandBuffer = commandQueue
            .makeCommandBuffer()!
        
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
        strokeEngineOutput s: StrokeEngine.Output
    ) {
//        let totalStampCount =
//            s.finalizedStamps.count +
//            s.nonFinalizedStamps.count
//        print("Drawing \(totalStampCount) stamps")
        
        let viewportSize = Size(
            Scalar(canvasWidth),
            Scalar(canvasHeight))
        
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
