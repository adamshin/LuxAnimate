//
//  AnimFrameEditorPaintToolState.swift
//

import UIKit

private let brushColor: Color = .brushBlack

class AnimFrameEditorPaintToolState: AnimFrameEditorToolState {
    
    weak var delegate: AnimFrameEditorToolStateDelegate?
    
    private let editorToolState: AnimEditorPaintToolState
    private let internalState: AnimFrameEditorBrushToolInternalState
    
    init(
        editorToolState: AnimEditorPaintToolState,
        drawingCanvasSize: PixelSize
    ) {
        self.editorToolState = editorToolState
        
        internalState = AnimFrameEditorBrushToolInternalState(
            canvasSize: drawingCanvasSize,
            brushMode: .paint)
        
        editorToolState.delegate = self
        internalState.delegate = self
    }
    
    func onFrame() {
        internalState.onFrame()
    }
    
    func drawingCanvasTexture() -> MTLTexture {
        internalState.drawingCanvasTexture()
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorPaintToolState:
    AnimFrameEditorBrushToolInternalStateDelegate
{
    func brush(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Brush? {
        editorToolState.brush
    }
    
    func color(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Color {
        brushColor
    }
    
    func scale(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Double {
        editorToolState.scale
    }
    
    func smoothing(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Double {
        editorToolState.smoothing
    }
    
    func workspaceViewSize(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Size {
        delegate?.layerContentSize(self) ?? .zero
    }
    
    func layerTransform(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> Matrix3 {
        delegate?.layerTransform(self) ?? .identity
    }
    
}

extension AnimFrameEditorPaintToolState: AnimEditorPaintToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: AnimEditorPaintToolState,
        quickTap: Bool
    ) {
        internalState.beginBrushStroke(quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ s: AnimEditorPaintToolState,
        stroke: BrushGestureRecognizer.Stroke
    ) {
        internalState.updateBrushStroke(stroke: stroke)
    }

    func onEndBrushStroke(
        _ s: AnimEditorPaintToolState
    ) {
        internalState.endBrushStroke()
    }

    func onCancelBrushStroke(
        _ s: AnimEditorPaintToolState
    ) {
        internalState.cancelBrushStroke()
    }
    
}
