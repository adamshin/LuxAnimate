//
//  AnimFrameEditSessionPaintToolState.swift
//
 
import UIKit
import Geometry
import Color
import BrushEngine

private let brushColor = AppConfig.paintBrushColor

class AnimFrameEditSessionPaintToolState:
    AnimFrameEditSessionToolState {
    
    weak var delegate: AnimFrameEditSessionToolStateDelegate?
    
    private let editorToolState: AnimEditorPaintToolState
    private let wrappedState: AnimFrameEditorBrushToolWrappedState
    
    init(
        editorToolState: AnimEditorPaintToolState,
        drawingCanvasSize: PixelSize
    ) {
        self.editorToolState = editorToolState
        
        wrappedState = AnimFrameEditorBrushToolWrappedState(
            canvasSize: drawingCanvasSize,
            brushMode: .paint)
        
        // TODO: Figure out communication between states
//        editorToolState.delegate = self
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

extension AnimFrameEditSessionPaintToolState:
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

// TODO: Figure out communication between this tool state and editor tool state

/*
extension AnimFrameEditorPaintToolState:
    AnimEditorPaintToolStateDelegate {
    
    func onBeginStroke(
        _ g: BrushGestureRecognizer,
        quickTap: Bool
    ) {
        internalState.beginStroke(
            quickTap: quickTap)
    }
    
    func onUpdateStroke(
        _ g: BrushGestureRecognizer,
        addedSamples: [BrushGestureRecognizer.Sample],
        predictedSamples: [BrushGestureRecognizer.Sample]
    ) {
        internalState.updateStroke(
            addedSamples: addedSamples,
            predictedSamples: predictedSamples)
    }
    
    func onUpdateStroke(
        _ g: BrushGestureRecognizer,
        sampleUpdates: [BrushGestureRecognizer.SampleUpdate]
    ) {
        internalState.updateStroke(
            sampleUpdates: sampleUpdates)
    }

    func onEndStroke(
        _ g: BrushGestureRecognizer
    ) {
        internalState.endStroke()
    }

    func onCancelStroke(
        _ g: BrushGestureRecognizer
    ) {
        internalState.cancelStroke()
    }
    
}
*/
