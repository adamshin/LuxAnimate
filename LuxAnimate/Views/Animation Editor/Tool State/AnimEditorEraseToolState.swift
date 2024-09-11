//
//  AnimEditorEraseToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorEraseToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: AnimEditorEraseToolState,
        quickTap: Bool)

    func onUpdateBrushStroke(
        _ s: AnimEditorEraseToolState,
        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: AnimEditorEraseToolState)

    func onCancelBrushStroke(
        _ s: AnimEditorEraseToolState)
    
}

class AnimEditorEraseToolState: AnimEditorToolState {
    
    weak var delegate: AnimEditorEraseToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = AnimEditorEraseToolControlsVC()
    
    private(set) var brush: Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        let brushConfig = AppConfig.eraseBrushConfig
        
        brush = try? Brush(
            configuration: brushConfig)
        
        scale = AnimEditorToolSettingsStore
            .eraseToolScale
        smoothing = AnimEditorToolSettingsStore
            .eraseToolSmoothing
        
        brushGestureRecognizer.gestureDelegate = self
        
        controlsVC.delegate = self
        controlsVC.scale = scale
        controlsVC.smoothing = smoothing
    }
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC
    ) {
        workspaceVC.addToolGestureRecognizer(
            brushGestureRecognizer)
        
        toolControlsVC.show(controlsVC)
    }
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC
    ) {
        workspaceVC.removeAllToolGestureRecognizers()
        toolControlsVC.show(nil)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }
    
}

// MARK: - Delegates

extension AnimEditorEraseToolState: AnimEditorEraseToolControlsVCDelegate {
    
    func onChangeScale(_ vc: AnimEditorEraseToolControlsVC) {
        scale = controlsVC.scale
        AnimEditorToolSettingsStore
            .eraseToolScale = scale
    }
    func onChangeSmoothing(_ vc: AnimEditorEraseToolControlsVC) {
        smoothing = controlsVC.smoothing
        AnimEditorToolSettingsStore.eraseToolSmoothing = smoothing
    }
    
}

extension AnimEditorEraseToolState: BrushGestureRecognizerGestureDelegate {
    
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
