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
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    
    // TODO: Controls view controller
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        // TODO: Allow user to pick brushes
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.paintBrushIDs.first!)
        
        scale = AnimEditorToolSettingsStore
            .brushToolScale
        smoothing = AnimEditorToolSettingsStore
            .brushToolSmoothing
        
//        controlsVC.delegate = self
//        controlsVC.scale = scale
//        controlsVC.smoothing = smoothing
    }
    
    func begin(workspaceVC: EditorWorkspaceVC) {
        workspaceVC.addOverlayGestureRecognizer(
            brushGestureRecognizer)

        // TODO: Add controls VC to workspace overlay.
    }

    func end(workspaceVC: EditorWorkspaceVC) {
        workspaceVC.removeAllOverlayGestureRecognizers()

        // TODO: Remove controls VC.
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }
    
}
