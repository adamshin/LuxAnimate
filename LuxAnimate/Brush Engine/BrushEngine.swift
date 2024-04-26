//
//  BrushEngine.swift
//

import Metal

protocol BrushEngineDelegate: AnyObject {
    func onUpdateCanvas(_ engine: BrushEngine)
    func onFinalizeStroke(_ engine: BrushEngine)
}

class BrushEngine {
    
    weak var delegate: BrushEngineDelegate?
    
    private let renderer: BrushEngineRenderer
    private let displayLink = BrushEngineDisplayLink()
    
    private var strokeEngine: BrushStrokeEngine?
    
    // MARK: - Initializer
    
    init(canvasSize: PixelSize) {
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
        color: Color,
        scale: Double,
        smoothingLevel: Double
    ) {
        renderer.resetStroke()
        
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
        renderer.update(stroke: strokeEngine.outputStroke)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvas(self)
        delegate?.onFinalizeStroke(self)
    }
    
    // MARK: - Frame
    
    @objc private func onFrame() {
        guard let strokeEngine else { return }
        
        strokeEngine.process()
        renderer.update(stroke: strokeEngine.outputStroke)
        
        delegate?.onUpdateCanvas(self)
    }
    
}
