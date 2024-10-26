//
//  AnimFrameEditorEraseToolState.swift
//

import UIKit
import Geometry
import Color
import BrushEngine

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
        internalState.canvasTexture
    }
    
    func setDrawingCanvasTextureContents(_ texture: MTLTexture) {
        internalState.setCanvasTextureContents(texture)
    }
    
}

// MARK: - Delegates

extension AnimFrameEditorEraseToolState:
    AnimFrameEditorBrushToolInternalStateDelegate
{
    func brush(
        _ s: AnimFrameEditorBrushToolInternalState
    ) -> BrushEngine.Brush? {
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
    
    func onUpdateCanvasTexture(
        _ s: AnimFrameEditorBrushToolInternalState
    ) { }
    
    func onEdit(
        _ s: AnimFrameEditorBrushToolInternalState,
        imageSet: DrawingAssetProcessor.ImageSet
    ) {
        delegate?.onEdit(
            self, imageSet: imageSet)
    }
    
}

extension AnimFrameEditorEraseToolState:
    AnimEditorEraseToolStateDelegate {
    
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
