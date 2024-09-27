//
//  AnimEditorPaintToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorPaintToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: AnimEditorPaintToolState,
        quickTap: Bool)

//    func onUpdateBrushStroke(
//        _ s: AnimEditorPaintToolState,
//        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: AnimEditorPaintToolState)

    func onCancelBrushStroke(
        _ s: AnimEditorPaintToolState)
    
}

class AnimEditorPaintToolState: AnimEditorToolState {
    
    weak var delegate: AnimEditorPaintToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = AnimEditorBrushToolControlsVC()
    
    private(set) var brush: Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        let brushConfig = AppConfig.paintBrushConfig
        
        brush = try? Brush(
            configuration: brushConfig)
        
        scale = AnimEditorToolSettingsStore
            .brushToolScale
        smoothing = AnimEditorToolSettingsStore
            .brushToolSmoothing
        
//        brushGestureRecognizer.gestureDelegate = self
        
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

extension AnimEditorPaintToolState: AnimEditorBrushToolControlsVCDelegate {
    
    func onChangeScale(_ vc: AnimEditorBrushToolControlsVC) {
        scale = controlsVC.scale
        AnimEditorToolSettingsStore
            .brushToolScale = scale
    }
    func onChangeSmoothing(_ vc: AnimEditorBrushToolControlsVC) {
        smoothing = controlsVC.smoothing
        AnimEditorToolSettingsStore.brushToolSmoothing = smoothing
    }
    
}

//extension AnimEditorPaintToolState: BrushGestureRecognizerGestureDelegate {
//    
//    func onBeginBrushStroke(quickTap: Bool) {
//        delegate?.onBeginBrushStroke(self, quickTap: quickTap)
//    }
//    
//    func onUpdateBrushStroke(
//        _ stroke: BrushGestureRecognizer.Stroke
//    ) {
//        delegate?.onUpdateBrushStroke(self, stroke: stroke)
//    }
//    
//    func onEndBrushStroke() {
//        delegate?.onEndBrushStroke(self)
//    }
//    
//    func onCancelBrushStroke() {
//        delegate?.onCancelBrushStroke(self)
//    }
//    
//}
