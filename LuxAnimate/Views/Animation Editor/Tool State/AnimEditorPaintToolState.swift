//
//  AnimEditorPaintToolState.swift
//

import UIKit
import BrushEngine

// TODO: Figure out how to communicate between
// AnimEditorToolState and tool state inside frame editor.
// Frame editor will be recreated whenever the user moves
// between frames, and will own the brush engine instance.

// Need to pass on input events and tool settings.

@MainActor
class AnimEditorPaintToolState: AnimEditorToolState {
    
    private let controlsVC = AnimEditorPaintToolControlsVC()
    private let brushGestureRecognizer = BrushGestureRecognizer()
    
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
    
}

extension AnimEditorPaintToolState:
    AnimEditorPaintToolControlsVC.Delegate {
    
    func onChangeScale(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore
            .paintToolScale = value
    }
    
    func onChangeSmoothing(
        _ vc: AnimEditorPaintToolControlsVC,
        _ value: Double
    ) {
        AnimEditorToolSettingsStore
            .paintToolSmoothing = value
    }
    
}
