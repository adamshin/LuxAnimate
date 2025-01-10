//
//  AnimFrameEditorBrushToolInternalState.swift
//

import UIKit
import Metal
import Geometry
import Color
import BrushEngine

@MainActor
protocol AnimFrameEditorBrushToolInternalStateDelegate: AnyObject {
    
    func brush(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> BrushEngine.Brush?
    
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
    
    private let canvas: BrushEngine.Canvas
    
    private let drawingAssetProcessor = DrawingAssetProcessor()
    
    init(
        canvasSize: PixelSize,
        brushMode: BrushEngine.BrushMode
    ) {
        canvas = BrushEngine.Canvas(
            width: canvasSize.width,
            height: canvasSize.height,
            debugRender: AppConfig.brushDebugRender,
            brushMode: brushMode,
            pixelFormat: AppConfig.pixelFormat,
            metalDevice: MetalInterface.shared.device,
            commandQueue: MetalInterface.shared.commandQueue)
        
        canvas.delegate = self
    }
    
    func onFrame() {
        canvas.onFrame()
    }
    
    var canvasTexture: MTLTexture {
        canvas.texture
    }
    
    func setCanvasTextureContents(_ texture: MTLTexture) {
        canvas.setTextureContents(texture)
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
        
        canvas.beginStroke(
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
        
        canvas.updateStroke(
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
        
        canvas.updateStroke(
            sampleUpdates: sampleUpdates)
    }
    
    func endStroke() {
        canvas.endStroke()
    }

    func cancelStroke() {
        canvas.cancelStroke()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorBrushToolInternalState:
    BrushEngine.Canvas.Delegate {
    
    func onUpdateTexture(_ c: Canvas) {
        delegate?.onUpdateCanvasTexture(self)
    }

    func onEndBrushStroke(_ c: Canvas) {
        do {
            // TODO: Do this on a background queue?
            let texture = try TextureCopier()
                .copy(canvas.texture)
            
            let imageSet = try drawingAssetProcessor
                .generate(sourceTexture: texture)
            
            delegate?.onEdit(self, imageSet: imageSet)
            
        } catch { }
    }
    
}
