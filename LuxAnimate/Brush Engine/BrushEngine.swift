//
//  BrushEngine.swift
//

import Foundation
import Metal

protocol BrushEngineDelegate: AnyObject {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine)
    
    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture)
    
}

extension BrushEngine {
    enum BrushMode {
        case paint
        case erase
    }
}

class BrushEngine {
    
    weak var delegate: BrushEngineDelegate?
    
    private let canvasTexture: MTLTexture
    
    private let renderer: BrushEngineRenderer
    private let strokeRenderer: BrushEngineStrokeRenderer
    
    private var strokeEngine: BrushStrokeEngine?
    
    // MARK: - Initializer
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushMode
    ) {
        canvasTexture = try! TextureCreator
            .createEmptyTexture(
                size: canvasSize,
                mipMapped: false)
        
        renderer = BrushEngineRenderer(
            canvasSize: canvasSize,
            brushMode: brushMode)
        
        strokeRenderer = BrushEngineStrokeRenderer(
            canvasSize: canvasSize)
    }
    
    // MARK: - Rendering
    
    private func draw() {
        renderer.draw(
            baseCanvasTexture: canvasTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
    }
    
    // MARK: - Interface
    
    func setCanvasTexture(_ texture: MTLTexture) {
        endStroke()
        
        try? TextureBlitter.blit(
            from: texture,
            to: canvasTexture)
        draw()
    }
    
    var activeCanvasTexture: MTLTexture {
        renderer.renderTarget
    }
    
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
        
        strokeEngine.processInput()
        
        strokeRenderer.drawIncrementalStroke(
            stroke: strokeEngine.outputStroke)
        
        draw()
        
        try? TextureBlitter.blit(
            from: renderer.renderTarget,
            to: canvasTexture,
            waitUntilCompleted: true)
        
        strokeRenderer.clearStroke()
        draw()
        
        self.strokeEngine = nil
        
        delegate?.onUpdateActiveCanvasTexture(self)
        
        delegate?.onFinalizeStroke(self,
            canvasTexture: canvasTexture)
    }
    
    func cancelStroke() {
        strokeRenderer.clearStroke()
        draw()
        
        self.strokeEngine = nil
        
        delegate?.onUpdateActiveCanvasTexture(self)
    }
    
    func onFrame() {
        guard let strokeEngine else { return }
        
        strokeEngine.processInput()
        
        strokeRenderer.drawIncrementalStroke(
            stroke: strokeEngine.outputStroke)
        
        draw()
        
        delegate?.onUpdateActiveCanvasTexture(self)
    }
    
}
