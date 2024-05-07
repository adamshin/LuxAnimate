//
//  BrushEngine.swift
//

import Metal

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
    
    let canvasSize: PixelSize
    
    private let renderer: BrushEngineRenderer
    private let displayLink = BrushEngineDisplayLink()
    
    private var brushMode: BrushMode = .brush
    private var strokeEngine: BrushStrokeEngine?
    
    // MARK: - Initializer
    
    init(canvasSize: PixelSize) {
        self.canvasSize = canvasSize
        
        renderer = BrushEngineRenderer(
            canvasSize: canvasSize)
        
        displayLink.setCallback { [weak self] in
            self?.onFrame()
        }
    }
    
    // MARK: - Canvas
    
    func setCanvasContents(_ texture: MTLTexture) {
        renderer.setCanvasContents(texture)
    }
    
    var canvasTexture: MTLTexture {
        renderer.canvasTexture
    }
    
    // MARK: - Stroke
    
    func beginStroke(
        brush: Brush,
        brushMode: BrushMode,
        color: Color,
        scale: Double,
        smoothingLevel: Double
    ) {
        self.brushMode = brushMode
        
        strokeEngine = BrushStrokeEngine(
            brush: brush,
            color: color,
            scale: scale,
            smoothingLevel: smoothingLevel)
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
    
    // MARK: - Frame
    
    @objc private func onFrame() {
        guard let strokeEngine else { return }
        
        strokeEngine.process()
        
        renderer.update(
            stroke: strokeEngine.outputStroke,
            brushMode: brushMode)
        
        delegate?.onUpdateCanvas(self)
    }
    
}
