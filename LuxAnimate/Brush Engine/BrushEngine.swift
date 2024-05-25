//
//  BrushEngine.swift
//

import Metal

// TODO: Reevaluate how this all works.
// Where should interim textures be stored?
// We don't want to take up more memory than necessary

extension BrushEngine {
    
    enum BrushMode {
        case brush
        case erase
    }
    
}

protocol BrushEngineDelegate: AnyObject {
    func onUpdateCanvas(_ engine: BrushEngine)
    func onFinalizeStroke(_ engine: BrushEngine)
}

class BrushEngine {
    
    weak var delegate: BrushEngineDelegate?
    
    private let canvasSize: PixelSize
    private let brushMode: BrushMode
    
    private let renderer: BrushEngineRenderer
    
    private var strokeEngine: BrushStrokeEngine?
    
    // MARK: - Initializer
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushMode
    ) {
        self.canvasSize = canvasSize
        self.brushMode = brushMode
        
        let erase = switch brushMode {
        case .brush: false
        case .erase: true
        }
        
        renderer = BrushEngineRenderer(
            canvasSize: canvasSize,
            erase: erase)
    }
    
    // MARK: - Canvas
    
    func setBaseCanvasTexture(_ texture: MTLTexture) {
        renderer.setBaseCanvasTexture(texture)
    }
    
    var canvas: MTLTexture {
        renderer.renderTarget
    }
    
    // MARK: - Stroke
    
    func beginStroke(
        brush: Brush,
        color: Color,
        scale: Double,
        quickTap: Bool,
        smoothing: Double
    ) {
        strokeEngine = BrushStrokeEngine(
            brush: brush,
            color: color,
            scale: scale,
            quickTap: quickTap,
            smoothing: smoothing)
    }
    
    func updateStroke(
        inputStroke: BrushStrokeEngine.InputStroke
    ) {
        strokeEngine?.update(inputStroke: inputStroke)
    }
    
    func endStroke() {
        guard let strokeEngine else { return }
        
        strokeEngine.process()
        
        renderer.update(
            stroke: strokeEngine.outputStroke,
            brushMode: brushMode)
        
        renderer.finalizeStroke()
        
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvas(self)
        delegate?.onFinalizeStroke(self)
    }
    
    func cancelStroke() {
        renderer.cancelStroke()
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvas(self)
    }
    
    func onFrame() {
        guard let strokeEngine else { return }
        
        strokeEngine.process()
        
        renderer.update(
            stroke: strokeEngine.outputStroke,
            brushMode: brushMode)
        
        delegate?.onUpdateCanvas(self)
    }
    
}
