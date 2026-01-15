//
//  AnimFrameEditSessionEraseToolState.swift
//
    
import UIKit
import Geometry
import Color
import BrushEngine

private let brushColor = Color.white

class AnimFrameEditSessionEraseToolState:
    AnimFrameEditSessionToolState {
    
    weak var delegate: AnimFrameEditSessionToolStateDelegate?
    
    private let editorToolState: AnimEditorEraseToolState
    private let wrappedState: AnimFrameEditorBrushToolWrappedState
    
    init(
        editorToolState: AnimEditorEraseToolState,
        drawingCanvasSize: PixelSize
    ) {
        self.editorToolState = editorToolState
        
        wrappedState = AnimFrameEditorBrushToolWrappedState(
            canvasSize: drawingCanvasSize,
            brushMode: .erase)
        
        editorToolState.brushGestureRecognizer
            .gestureDelegate = wrappedState
        
        wrappedState.delegate = self
    }
    
    func onFrame() {
        wrappedState.onFrame()
    }
    
    func drawingCanvasTexture() -> MTLTexture {
        wrappedState.canvasTexture
    }
    
    func setDrawingCanvasTextureContents(_ texture: MTLTexture) {
        wrappedState.setCanvasTextureContents(texture)
    }
    
}

// MARK: - Delegates

extension AnimFrameEditSessionEraseToolState:
    AnimFrameEditorBrushToolWrappedStateDelegate
{
    func brush(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> BrushEngine.Brush? {
        editorToolState.brush
    }
    
    func color(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Color {
        brushColor
    }
    
    func scale(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Double {
        editorToolState.scale
    }
    
    func smoothing(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Double {
        editorToolState.smoothing
    }
    
    func workspaceViewSize(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Size {
        delegate?.workspaceViewSize(self) ?? .zero
    }
    
    func workspaceTransform(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> EditorWorkspaceTransform {
        delegate?.workspaceTransform(self) ?? .identity
    }
    
    func layerContentSize(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Size {
        delegate?.layerContentSize(self) ?? .zero
    }
    
    func layerTransform(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) -> Matrix3 {
        delegate?.layerTransform(self) ?? .identity
    }
    
    func onUpdateCanvasTexture(
        _ s: AnimFrameEditorBrushToolWrappedState
    ) { }
    
    func onRequestEdit(
        _ s: AnimFrameEditorBrushToolWrappedState,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        delegate?.onRequestEdit(self, imageSet: imageSet)
    }
    
}
