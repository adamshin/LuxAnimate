//
//  AnimFrameEditorBrushToolInternalState.swift
//

import UIKit
import Metal

@MainActor
protocol AnimFrameEditorBrushToolInternalStateDelegate: AnyObject {
    
    func brush(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Brush?
    
    func color(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Color
    
    func scale(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Double
    
    func smoothing(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Double
    
    func workspaceViewSize(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> EditorWorkspaceTransform
    
    func layerContentSize(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Size
    
    func layerTransform(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Matrix3
    
    func onUpdateCanvasTexture(
        _ s: AnimFrameEditorBrushToolInternalState)
    
    func onEdit(
        _ s: AnimFrameEditorBrushToolInternalState,
        imageSet: DrawingAssetProcessor.ImageSet)
    
}

@MainActor
class AnimFrameEditorBrushToolInternalState {
    
    weak var delegate: AnimFrameEditorBrushToolInternalStateDelegate?
    
    private let brushEngine: BrushEngine
    
    private let drawingAssetProcessor = DrawingAssetProcessor()
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushEngine.BrushMode
    ) {
        brushEngine = BrushEngine(
            canvasSize: canvasSize,
            brushMode: brushMode)
        
        brushEngine.delegate = self
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    var canvasTexture: MTLTexture {
        brushEngine.canvasTexture
    }
    
    func setCanvasTextureContents(_ texture: MTLTexture) {
        brushEngine.setCanvasTextureContents(texture)
    }
    
    func beginStroke(
        quickTap: Bool
    ) {
        guard let delegate,
            let brush = delegate.brush(self)
        else { return }
        
        let color = delegate.color(self)
        let scale = delegate.scale(self)
        let smoothing = delegate.smoothing(self)
        
        brushEngine.beginStroke(
            brush: brush,
            color: color,
            scale: scale,
            smoothing: smoothing,
            quickTap: quickTap)
    }
    
    func updateStroke(
        addedSamples: [BrushGestureRecognizer.Sample],
        predictedSamples: [BrushGestureRecognizer.Sample]
    ) {
        guard let delegate else { return }
        
        let adapter = AnimEditorBrushSampleAdapter(
            workspaceViewSize: delegate.workspaceViewSize(self),
            workspaceTransform: delegate.workspaceTransform(self),
            layerContentSize: delegate.layerContentSize(self),
            layerTransform: delegate.layerTransform(self))
        
        let addedSamples = addedSamples.map {
            adapter.convert(sample: $0)
        }
        let predictedSamples = predictedSamples.map {
            adapter.convert(sample: $0)
        }
        
        brushEngine.updateStroke(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func updateStroke(
        sampleUpdates: [BrushGestureRecognizer.SampleUpdate]
    ) {
        guard let delegate else { return }
        
        let adapter = AnimEditorBrushSampleAdapter(
            workspaceViewSize: delegate.workspaceViewSize(self),
            workspaceTransform: delegate.workspaceTransform(self),
            layerContentSize: delegate.layerContentSize(self),
            layerTransform: delegate.layerTransform(self))
        
        let sampleUpdates = sampleUpdates.map {
            adapter.convert(sampleUpdate: $0)
        }
        
        brushEngine.updateStroke(
            sampleUpdates: sampleUpdates)
    }
    
    func endStroke() {
        brushEngine.endStroke()
    }

    func cancelStroke() {
        brushEngine.cancelStroke()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorBrushToolInternalState:
    BrushEngine.Delegate {
    
    func onUpdateCanvasTexture(
        _ e: BrushEngine
    ) {
        delegate?.onUpdateCanvasTexture(self)
    }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) {
        do {
            // TODO: Do this on a background queue?
            let texture = try TextureCopier
                .copy(canvasTexture)
            
            let imageSet = try drawingAssetProcessor
                .generate(sourceTexture: texture)
            
            delegate?.onEdit(self, imageSet: imageSet)
            
        } catch { }
    }
    
}
