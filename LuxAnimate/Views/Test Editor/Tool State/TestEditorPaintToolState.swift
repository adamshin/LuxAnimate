//
//  TestEditorPaintToolState.swift
//

import UIKit

protocol TestEditorPaintToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: TestEditorPaintToolState,
        quickTap: Bool)

    func onUpdateBrushStroke(
        _ s: TestEditorPaintToolState,
        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: TestEditorPaintToolState)

    func onCancelBrushStroke(
        _ s: TestEditorPaintToolState)
    
}

class TestEditorPaintToolState: TestEditorToolState {
    
    weak var delegate: TestEditorPaintToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = TestEditorBrushToolControlsVC()
    
    private(set) var brush: Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        let brushConfig = AppConfig.paintBrushConfig
        
        brush = try? Brush(
            configuration: brushConfig)
        
        scale = TestEditorToolSettingsStore
            .brushToolScale
        smoothing = TestEditorToolSettingsStore
            .brushToolSmoothing
        
        brushGestureRecognizer.gestureDelegate = self
        
        controlsVC.delegate = self
        controlsVC.scale = scale
        controlsVC.smoothing = smoothing
    }
    
    func beginState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC
    ) {
        workspaceVC.addToolGestureRecognizer(
            brushGestureRecognizer)
        
        toolControlsVC.show(controlsVC)
    }
    
    func endState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC
    ) {
        workspaceVC.removeAllToolGestureRecognizers()
        toolControlsVC.show(nil)
    }
    
}

// MARK: - Delegates

extension TestEditorPaintToolState: TestEditorBrushToolControlsVCDelegate {
    
    func onChangeScale(_ vc: TestEditorBrushToolControlsVC) {
        scale = controlsVC.scale
        TestEditorToolSettingsStore
            .brushToolScale = scale
    }
    func onChangeSmoothing(_ vc: TestEditorBrushToolControlsVC) {
        smoothing = controlsVC.smoothing
        TestEditorToolSettingsStore.brushToolSmoothing = smoothing
    }
    
}

extension TestEditorPaintToolState: BrushGestureRecognizerGestureDelegate {
    
    func onBeginBrushStroke(quickTap: Bool) {
        delegate?.onBeginBrushStroke(self, quickTap: quickTap)
    }
    
    func onUpdateBrushStroke(
        _ stroke: BrushGestureRecognizer.Stroke
    ) {
        delegate?.onUpdateBrushStroke(self, stroke: stroke)
    }
    
    func onEndBrushStroke() {
        delegate?.onEndBrushStroke(self)
    }
    
    func onCancelBrushStroke() {
        delegate?.onCancelBrushStroke(self)
    }
    
}
