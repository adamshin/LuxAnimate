//
//  AnimFrameEditorEraseToolState.swift
//

import UIKit

class AnimFrameEditorEraseToolState: AnimFrameEditorToolState {
    
    weak var delegate: AnimFrameEditorToolStateDelegate?
    
    private let editorToolState: AnimEditorEraseToolState
    private let internalState: AnimFrameEditorBrushToolInternalState
    
    init(
        editorToolState: AnimEditorEraseToolState,
        drawingCanvasSize: PixelSize
    ) {
        self.editorToolState = editorToolState
        
        internalState = AnimFrameEditorBrushToolInternalState(
            canvasSize: drawingCanvasSize,
            brushMode: .erase)
        
        editorToolState.delegate = self
        internalState.delegate = self
    }
    
    func onFrame() {
        internalState.onFrame()
    }
    
    func drawingCanvasTexture() -> MTLTexture {
        internalState.activeCanvasTexture
    }
    
    func setDrawingCanvasTexture(_ texture: MTLTexture) {
        internalState.setCanvasTexture(texture)
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorEraseToolState:
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
        .black
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
    
    func onUpdateActiveCanvasTexture(
        _ s: AnimFrameEditorBrushToolInternalState
    ) { }
    
    func onFinalizeStroke(
        _ s: AnimFrameEditorBrushToolInternalState,
        canvasTexture: MTLTexture
    ) {
        delegate?.onEdit(
            self,
            drawingTexture: canvasTexture)
    }
    
}

extension AnimFrameEditorEraseToolState: AnimEditorEraseToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: AnimEditorEraseToolState,
        quickTap: Bool
    ) {
        internalState.beginBrushStroke(quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ s: AnimEditorEraseToolState,
        stroke: BrushGestureRecognizer.Stroke
    ) {
        internalState.updateBrushStroke(stroke: stroke)
    }

    func onEndBrushStroke(
        _ s: AnimEditorEraseToolState
    ) {
        internalState.endBrushStroke()
    }

    func onCancelBrushStroke(
        _ s: AnimEditorEraseToolState
    ) {
        internalState.cancelBrushStroke()
    }
    
}
