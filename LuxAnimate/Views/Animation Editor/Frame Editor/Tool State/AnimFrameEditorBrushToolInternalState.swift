//
//  AnimFrameEditorBrushToolInternalState.swift
//

import UIKit
import Metal

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
    
}

class AnimFrameEditorBrushToolInternalState {
    
    weak var delegate: AnimFrameEditorBrushToolInternalStateDelegate?
    
    private let brushEngine: BrushEngine
    
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
    
    func beginBrushStroke(quickTap: Bool) {
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
    
    func updateBrushStroke(
        stroke: BrushGestureRecognizer.Stroke
    ) {
        guard let delegate else { return }
        
        let workspaceViewSize = delegate.workspaceViewSize(self)
        let workspaceTransform = delegate.workspaceTransform(self)
        let layerContentSize = delegate.layerContentSize(self)
        let layerTransform = delegate.layerTransform(self)
        
        let inputStroke = AnimEditorBrushStrokeAdapter.convert(
            stroke: stroke,
            workspaceViewSize: workspaceViewSize,
            workspaceTransform: workspaceTransform,
            layerContentSize: layerContentSize,
            layerTransform: layerTransform)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }
    
    func endBrushStroke() {
        brushEngine.endStroke()
    }

    func cancelBrushStroke() {
        brushEngine.cancelStroke()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorBrushToolInternalState: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}
