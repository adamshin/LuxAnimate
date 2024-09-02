//
//  AnimFrameEditorEraseToolState.swift
//

import UIKit
import Metal

protocol AnimFrameEditorEraseToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: AnimFrameEditorEraseToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: AnimFrameEditorEraseToolState
    ) -> AnimWorkspaceTransform
    
    func layerContentSize(
        _ s: AnimFrameEditorEraseToolState
    ) -> Size
    
    func layerTransform(
        _ s: AnimFrameEditorEraseToolState
    ) -> Matrix3
    
    // TODO: Methods for reporting project edits
    
}

class AnimFrameEditorEraseToolState: AnimFrameEditorToolState {
    
    weak var delegate: AnimFrameEditorEraseToolStateDelegate?
    
    private let editorToolState: AnimEditorEraseToolState
    private let drawingCanvasSize: PixelSize
    
    private let brushEngine: BrushEngine
    
    init(
        editorToolState: AnimEditorEraseToolState,
        drawingCanvasSize: PixelSize,
        drawingCanvasTexture: MTLTexture?
    ) {
        self.editorToolState = editorToolState
        self.drawingCanvasSize = drawingCanvasSize
        
        brushEngine = BrushEngine(
            canvasSize: drawingCanvasSize,
            brushMode: .erase)
        
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

extension AnimFrameEditorEraseToolState: AnimEditorEraseToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: AnimEditorEraseToolState,
        quickTap: Bool
    ) {
        guard let brush = editorToolState.brush
        else { return }
        
        brushEngine.beginStroke(
            brush: brush,
            color: .black,
            scale: editorToolState.scale,
            smoothing: editorToolState.smoothing,
            quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ s: AnimEditorEraseToolState,
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
        _ s: AnimEditorEraseToolState
    ) {
        brushEngine.endStroke()
    }

    func onCancelBrushStroke(
        _ s: AnimEditorEraseToolState
    ) {
        brushEngine.cancelStroke()
    }
    
}

extension AnimFrameEditorEraseToolState: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}

