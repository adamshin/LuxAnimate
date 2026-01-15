//
//  AnimEditorPaintToolState.swift
//

import UIKit
import BrushEngine

@MainActor
class AnimEditorPaintToolState: AnimEditorToolState {
    
    let controlsVC = AnimEditorPaintToolControlsVC()
    let brushGestureRecognizer = BrushGestureRecognizer()
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        // TODO: Allow user to pick brushes
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.paintBrushIDs.first!)
        
        scale = AnimEditorToolSettingsStore.paintToolScale
        smoothing = AnimEditorToolSettingsStore.paintToolSmoothing
        
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
    
    func toggleExpandedControls() {
        // TODO: Toggle brush picker menu
    }
    
}

extension AnimEditorPaintToolState:
    AnimEditorPaintToolControlsVC.Delegate {
    
    func onChangeScale(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore.paintToolScale = value
        scale = value
    }
    
    func onChangeSmoothing(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore.paintToolSmoothing = value
        smoothing = value
    }
    
}
