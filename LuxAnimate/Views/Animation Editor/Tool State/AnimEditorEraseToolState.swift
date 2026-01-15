//
//  AnimEditorEraseToolState.swift
//

import UIKit
import BrushEngine

@MainActor
class AnimEditorEraseToolState: AnimEditorToolState {
    
    let controlsVC = AnimEditorPaintToolControlsVC()
    let brushGestureRecognizer = BrushGestureRecognizer()
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        // TODO: Allow user to pick brushes
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.eraseBrushID)
        
        scale = AnimEditorToolSettingsStore.eraseToolScale
        smoothing = AnimEditorToolSettingsStore.eraseToolSmoothing
        
        controlsVC.delegate = self
        controlsVC.setScale(scale)
        controlsVC.setSmoothing(smoothing)
    }
    
    var workspaceControlsVC: UIViewController? {
        controlsVC
    }
    
    var workspaceGestureRecognizers: [UIGestureRecognizer] {
        [brushGestureRecognizer]
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }
    
}

extension AnimEditorEraseToolState:
    AnimEditorPaintToolControlsVC.Delegate {
    
    func onChangeScale(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore.eraseToolScale = value
        scale = value
    }
    
    func onChangeSmoothing(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore.eraseToolSmoothing = value
        smoothing = value
    }
    
}

