//
//  BrushEngine2.swift
//

import Foundation
import Metal

extension BrushEngine2 {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onUpdateActiveCanvasTexture(
            _ e: BrushEngine2)
        
        func onFinalizeStroke(
            _ e: BrushEngine2,
            canvasTexture: MTLTexture)
        
    }
    
    enum BrushMode {
        case paint
        case erase
    }
    
}

@MainActor
class BrushEngine2 {
    
    weak var delegate: Delegate?
    
    private let canvasTexture: MTLTexture
    
//    private let renderer: BrushEngineRenderer
//    private let strokeRenderer: BrushEngineStrokeRenderer
    
    private var strokeEngine: BrushStrokeEngine2?
    
    // MARK: - Initializer
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushEngine2.BrushMode
    ) {
        canvasTexture = try! TextureCreator
            .createEmptyTexture(
                size: canvasSize,
                mipMapped: false)
        
//        renderer = BrushEngineRenderer(
//            canvasSize: canvasSize,
//            brushMode: brushMode)
        
//        strokeRenderer = BrushEngineStrokeRenderer(
//            canvasSize: canvasSize)
    }
    
    // MARK: - Rendering
    
    private func draw() {
//        renderer.draw(
//            baseCanvasTexture: canvasTexture,
//            strokeTexture: strokeRenderer.fullStrokeTexture)
    }
    
    // MARK: - Interface
    
//    func setCanvasTexture(_ texture: MTLTexture) {
//        endStroke()
//        
//        try? TextureBlitter.blit(
//            from: texture,
//            to: canvasTexture)
//        draw()
//    }
    
//    var activeCanvasTexture: MTLTexture {
//        renderer.renderTarget
//    }
    
    func beginStroke(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool
    ) {
        strokeEngine = BrushStrokeEngine2(
            brush: brush,
            color: color,
            scale: scale,
            smoothing: smoothing,
            quickTap: quickTap)
    }
    
    func updateStroke(
        inputStroke: BrushStrokeEngine.InputStroke
    ) {
//        strokeEngine?.update(inputStroke: inputStroke)
    }
    
    func endStroke() {
//        guard let strokeEngine else { return }
//        
//        strokeEngine.processInput()
//        
//        strokeRenderer.drawIncrementalStroke(
//            stroke: strokeEngine.outputStroke)
//        
//        draw()
//        
//        try? TextureBlitter.blit(
//            from: renderer.renderTarget,
//            to: canvasTexture,
//            waitUntilCompleted: true)
//        
//        strokeRenderer.clearStroke()
//        draw()
//        
//        self.strokeEngine = nil
//        
//        delegate?.onUpdateActiveCanvasTexture(self)
//        
//        delegate?.onFinalizeStroke(self,
//            canvasTexture: canvasTexture)
    }
    
    func cancelStroke() {
//        strokeRenderer.clearStroke()
//        draw()
//        
//        self.strokeEngine = nil
//        
//        delegate?.onUpdateActiveCanvasTexture(self)
    }
    
    func onFrame() {
//        guard let strokeEngine else { return }
//        
//        strokeEngine.processInput()
//        
//        strokeRenderer.drawIncrementalStroke(
//            stroke: strokeEngine.outputStroke)
//        
//        draw()
//        
//        delegate?.onUpdateActiveCanvasTexture(self)
    }
    
}
