//
//  TestEditorEraseToolState.swift
//

import UIKit

protocol TestEditorEraseToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: TestEditorEraseToolState,
        quickTap: Bool)

    func onUpdateBrushStroke(
        _ s: TestEditorEraseToolState,
        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: TestEditorEraseToolState)

    func onCancelBrushStroke(
        _ s: TestEditorEraseToolState)
    
}

class TestEditorEraseToolState: TestEditorToolState {
    
    weak var delegate: TestEditorEraseToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = TestEditorEraseToolControlsVC()
    
    private(set) var brush: Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        let brushConfig = AppConfig.eraseBrushConfig
        
        brush = try? Brush(
            configuration: brushConfig)
        
        scale = TestEditorToolSettingsStore
            .eraseToolScale
        smoothing = TestEditorToolSettingsStore
            .eraseToolSmoothing
        
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

extension TestEditorEraseToolState: TestEditorEraseToolControlsVCDelegate {
    
    func onChangeScale(_ vc: TestEditorEraseToolControlsVC) {
        scale = controlsVC.scale
        TestEditorToolSettingsStore
            .eraseToolScale = scale
    }
    func onChangeSmoothing(_ vc: TestEditorEraseToolControlsVC) {
        smoothing = controlsVC.smoothing
        TestEditorToolSettingsStore.eraseToolSmoothing = smoothing
    }
    
}

extension TestEditorEraseToolState: BrushGestureRecognizerGestureDelegate {
    
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
