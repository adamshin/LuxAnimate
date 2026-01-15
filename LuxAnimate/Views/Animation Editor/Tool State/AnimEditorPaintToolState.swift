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
        scale = AnimEditorToolSettingsStore.paintToolScale
        smoothing = AnimEditorToolSettingsStore.paintToolSmoothing
        
        controlsVC.delegate = self
        controlsVC.setScale(scale)
        controlsVC.setSmoothing(smoothing)
        
        setBrush(id: AppConfig.paintBrushIDs.first!)
    }
    
    func setBrush(id: String) {
        brush = try? BrushLibraryManager.loadBrush(id: id)
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
        controlsVC.toggleExpandedControls()
    }
    
}

extension AnimEditorPaintToolState:
    AnimEditorPaintToolControlsVC.Delegate {
    
    func onSelectBrush(
        _ vc: AnimEditorPaintToolControlsVC,
        id: String
    ) {
        setBrush(id: id)
    }
    
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
