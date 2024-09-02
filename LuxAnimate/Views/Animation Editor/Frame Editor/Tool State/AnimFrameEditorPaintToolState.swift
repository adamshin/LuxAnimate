//
//  AnimFrameEditorPaintToolState.swift
//

import UIKit
import Metal

protocol AnimFrameEditorPaintToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorPaintToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditorPaintToolState
    ) -> AnimWorkspaceTransform
    
    func layerContentSize(
        _ s: AnimFrameEditorPaintToolState
    ) -> Size
    
    func layerTransform(
        _ s: AnimFrameEditorPaintToolState
    ) -> Matrix3
    
    // TODO: Methods for reporting project edits
    
}

class AnimFrameEditorPaintToolState: AnimFrameEditorToolState {
    
    weak var delegate: AnimFrameEditorPaintToolStateDelegate?
    
    private let editorToolState: AnimEditorPaintToolState
    private let drawingCanvasSize: PixelSize
    
    private let brushEngine: BrushEngine
    
    init(
        editorToolState: AnimEditorPaintToolState,
        drawingCanvasSize: PixelSize,
        drawingCanvasTexture: MTLTexture?
    ) {
        self.editorToolState = editorToolState
        self.drawingCanvasSize = drawingCanvasSize
        
        brushEngine = BrushEngine(
            canvasSize: drawingCanvasSize,
            brushMode: .paint)
        
        if let drawingCanvasTexture {
            brushEngine.setCanvasTexture(drawingCanvasTexture)
        }
        
        editorToolState.delegate = self
        brushEngine.delegate = self
    }
    
    func onFrame() {
        brushEngine.onFrame()
    }
    
    func drawingCanvasTexture() -> any MTLTexture {
        brushEngine.activeCanvasTexture
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorPaintToolState: AnimEditorPaintToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: AnimEditorPaintToolState,
        quickTap: Bool
    ) {
        guard let brush = editorToolState.brush
        else { return }
        
        brushEngine.beginStroke(
            brush: brush,
            color: .brushBlack,
            scale: editorToolState.scale,
            smoothing: editorToolState.smoothing,
            quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ s: AnimEditorPaintToolState,
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

    func onEndBrushStroke(
        _ s: AnimEditorPaintToolState
    ) {
        brushEngine.endStroke()
    }

    func onCancelBrushStroke(
        _ s: AnimEditorPaintToolState
    ) {
        brushEngine.cancelStroke()
    }
    
}

extension AnimFrameEditorPaintToolState: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}
