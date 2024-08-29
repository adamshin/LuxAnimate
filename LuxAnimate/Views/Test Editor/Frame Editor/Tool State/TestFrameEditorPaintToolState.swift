//
//  TestFrameEditorPaintToolState.swift
//

import UIKit
import Metal

protocol TestFrameEditorPaintToolStateDelegate: AnyObject {
    
    func workspaceViewSize(
        _ s: TestFrameEditorPaintToolState
    ) -> Size
    
    func workspaceTransform(
        _ s: TestFrameEditorPaintToolState
    ) -> TestWorkspaceTransform
    
    func layerContentSize(
        _ s: TestFrameEditorPaintToolState
    ) -> Size
    
    func layerTransform(
        _ s: TestFrameEditorPaintToolState
    ) -> Matrix3
    
    // TODO: Methods for reporting project edits
    
}

class TestFrameEditorPaintToolState: TestFrameEditorToolState {
    
    weak var delegate: TestFrameEditorPaintToolStateDelegate?
    
    private let editorToolState: TestEditorPaintToolState
    private let drawingCanvasSize: PixelSize
    
    private let brushEngine: BrushEngine
    
    init(
        editorToolState: TestEditorPaintToolState,
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

extension TestFrameEditorPaintToolState: TestEditorPaintToolStateDelegate {
    
    func onBeginBrushStroke(
        _ s: TestEditorPaintToolState,
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
        _ s: TestEditorPaintToolState,
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
        _ s: TestEditorPaintToolState
    ) {
        brushEngine.endStroke()
    }

    func onCancelBrushStroke(
        _ s: TestEditorPaintToolState
    ) {
        brushEngine.cancelStroke()
    }
    
}

extension TestFrameEditorPaintToolState: BrushEngineDelegate {
    
    func onUpdateActiveCanvasTexture(
        _ e: BrushEngine
    ) { }

    func onFinalizeStroke(
        _ e: BrushEngine,
        canvasTexture: MTLTexture
    ) { }
    
}
