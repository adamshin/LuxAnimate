//
//  TestFrameEditorEraseToolState.swift
//

import UIKit
import Metal

protocol TestFrameEditorEraseToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: TestFrameEditorEraseToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: TestFrameEditorEraseToolState
    ) -> TestWorkspaceTransform
    
    func layerContentSize(
        _ s: TestFrameEditorEraseToolState
    ) -> Size
    
    func layerTransform(
        _ s: TestFrameEditorEraseToolState
    ) -> Matrix3
    
    // TODO: Methods for reporting project edits
    
}

class TestFrameEditorEraseToolState: TestFrameEditorToolState {
    
    weak var delegate: TestFrameEditorEraseToolStateDelegate?
    
    private let editorToolState: TestEditorEraseToolState
    private let drawingCanvasSize: PixelSize
    
    private let brushEngine: BrushEngine
    
    init(
        editorToolState: TestEditorEraseToolState,
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
    
    func clearCanvas() {
        let texture = try! TextureCreator
            .createEmptyTexture(
                size: drawingCanvasSize,
                mipMapped: false)
        
        brushEngine.setCanvasTexture(texture)
    }
    
    func drawingCanvasTexture() -> any MTLTexture {
        brushEngine.activeCanvasTexture
    }
    
}

// MARK: - Delegates

extension TestFrameEditorEraseToolState: TestEditorEraseToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: TestEditorEraseToolState,
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
        _ s: TestEditorEraseToolState,
        stroke: BrushGestureRecognizer.Stroke
    ) {
        guard let delegate else { return }
        
        let workspaceViewSize = delegate.workspaceViewSize(self)
        let workspaceTransform = delegate.workspaceTransform(self)
        let layerContentSize = delegate.layerContentSize(self)
        let layerTransform = delegate.layerTransform(self)
        
        let inputStroke = TestBrushStrokeAdapter.convert(
            stroke: stroke,
            workspaceViewSize: workspaceViewSize,
            workspaceTransform: workspaceTransform,
            layerContentSize: layerContentSize,
            layerTransform: layerTransform)
        
        brushEngine.updateStroke(inputStroke: inputStroke)
    }

    func onEndBrushStroke(
        _ s: TestEditorEraseToolState
    ) {
        brushEngine.endStroke()
    }

    func onCancelBrushStroke(
        _ s: TestEditorEraseToolState
    ) {
        brushEngine.cancelStroke()
    }
    
}

extension TestFrameEditorEraseToolState: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}

