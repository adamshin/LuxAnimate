
import Metal
import Geometry
import Render

class StrokeRenderer {
    
    private let canvasWidth: Int
    private let canvasHeight: Int
    private let commandQueue: MTLCommandQueue
    
    private let stampRenderer: BrushStampRenderer
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
        
        stampRenderer = BrushStampRenderer(
            pixelFormat: pixelFormat,
            metalDevice: metalDevice)
        
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
    
    // MARK: - Render
    
    func drawStamps(
        target: MTLTexture,
        viewportSize: Size,
        sprites: [BrushStampRenderer.Sprite],
        brush: Brush
    ) {
        let commandBuffer = commandQueue
            .makeCommandBuffer()!
        
        stampRenderer.drawSprites(
            commandBuffer: commandBuffer,
            target: target,
            viewportSize: viewportSize,
            shapeTexture: brush.shapeTexture,
            textureTexture: brush.textureTexture,
            sprites: sprites,
            blendMode: .normal,
            sampleMode: .linearClampEdgeToBlack,
            colorMode: .brush)
        
        commandBuffer.commit()
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
            Double(canvasWidth),
            Double(canvasHeight))
        
        drawStamps(
            target: finalizedStrokeTexture,
            viewportSize: viewportSize,
            sprites: s.finalizedStampSprites,
            brush: s.brush)
        
        try? textureBlitter.blit(
            from: finalizedStrokeTexture,
            to: fullStrokeTexture)
        
        drawStamps(
            target: fullStrokeTexture,
            viewportSize: viewportSize,
            sprites: s.nonFinalizedStampSprites,
            brush: s.brush)
    }
    
}
