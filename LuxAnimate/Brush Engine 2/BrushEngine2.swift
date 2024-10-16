//
//  BrushEngine2.swift
//

import Foundation
import Metal

// MARK: - Structs

extension BrushEngine2 {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onUpdateCanvasTexture(
            _ e: BrushEngine2)
        
        func onFinalizeStroke(
            _ e: BrushEngine2,
            canvasTexture: MTLTexture)
    }
    
    enum BrushMode {
        case paint
        case erase
    }
    
    struct InputSample {
        var isPredicted: Bool
        var updateID: Int?
        
        var timeOffset: TimeInterval
        var position: Vector
        
        var pressure: Double
        var altitude: Double
        var azimuth: Double
        var roll: Double
        
        var isPressureEstimated: Bool
        var isAltitudeEstimated: Bool
        var isAzimuthEstimated: Bool
        var isRollEstimated: Bool
        
        var hasEstimatedValues: Bool {
            isPressureEstimated ||
            isAltitudeEstimated ||
            isAzimuthEstimated ||
            isRollEstimated
        }
        var isFinalized: Bool {
            !isPredicted && !hasEstimatedValues
        }
    }
    
    struct InputSampleUpdate {
        var updateID: Int
        
        var pressure: Double?
        var altitude: Double?
        var azimuth: Double?
        var roll: Double?
    }
    
    struct Sample {
        var timeOffset: TimeInterval
        
        var position: Vector
        var pressure: Double
        var altitude: Double
        var azimuth: Double
        var roll: Double
        
        var isFinalized: Bool
        
        // TODO: Index?
    }
    
    struct Stamp {
        var position: Vector
        var size: Double
        var rotation: Double
        var alpha: Double
        var color: Color
        
        var offset: Vector
        var strokeDistance: Double
        
        var isFinalized: Bool
    }
    
}

// MARK: - BrushEngine2

@MainActor
class BrushEngine2 {
    
    weak var delegate: Delegate?
    
    private let baseCanvasTexture: MTLTexture
    
    private let renderer: BrushEngine2Renderer
    private let strokeRenderer: BrushEngine2StrokeRenderer // TODO: move to stroke engine?
    
    private var strokeEngine: BrushStrokeEngine2?
    
    // MARK: - Initializer
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushEngine2.BrushMode
    ) {
        baseCanvasTexture = try! TextureCreator
            .createEmptyTexture(
                size: canvasSize,
                mipMapped: false)
        
        renderer = BrushEngine2Renderer(
            canvasSize: canvasSize,
            brushMode: brushMode)
        
        strokeRenderer = BrushEngine2StrokeRenderer(
            canvasSize: canvasSize)
    }
    
    // MARK: - Interface
    
    var canvasTexture: MTLTexture {
        renderer.renderTarget
    }
    
    func setCanvasTextureContents(_ texture: MTLTexture) {
        endStroke()
        
        try? TextureBlitter.blit(
            from: texture,
            to: baseCanvasTexture)
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: nil)
    }
    
    func beginStroke(
        brush: Brush,
        color: Color,
        scale: Double,
        smoothing: Double,
        quickTap: Bool,
        startTime: TimeInterval
    ) {
        strokeEngine = BrushStrokeEngine2(
            brush: brush,
            color: color,
            scale: scale,
            smoothing: smoothing,
            quickTap: quickTap,
            startTime: startTime)
    }
    
    func updateStroke(
        addedSamples: [InputSample],
        predictedSamples: [InputSample]
    ) {
        strokeEngine?.update(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func updateStroke(
        sampleUpdates: [InputSampleUpdate]
    ) {
        strokeEngine?.update(
            sampleUpdates: sampleUpdates)
    }
    
    func endStroke() {
        guard let strokeEngine else { return }
        
        let strokeProcessOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            brush: strokeProcessOutput.brush,
            stamps: strokeProcessOutput.stamps)
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        try? TextureBlitter.blit(
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
    }
    
    func cancelStroke() {
        strokeRenderer.clearStroke()
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: nil)
        
        self.strokeEngine = nil
        
        delegate?.onUpdateCanvasTexture(self)
    }
    
    func onFrame() {
        guard let strokeEngine else { return }
        
        let strokeProcessOutput = strokeEngine.process()
        
        strokeRenderer.drawIncrementalStroke(
            brush: strokeProcessOutput.brush,
            stamps: strokeProcessOutput.stamps)
        
        renderer.draw(
            baseCanvasTexture: baseCanvasTexture,
            strokeTexture: strokeRenderer.fullStrokeTexture)
        
        delegate?.onUpdateCanvasTexture(self)
    }
    
}
