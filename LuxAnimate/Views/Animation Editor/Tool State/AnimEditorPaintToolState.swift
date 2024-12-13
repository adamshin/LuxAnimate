//
//  AnimEditorPaintToolState.swift
//

import UIKit
import BrushEngine

@MainActor
protocol AnimEditorPaintToolStateDelegate:
    BrushGestureRecognizer.GestureDelegate { }

class AnimEditorPaintToolState: AnimEditorToolState {
    
    weak var delegate: AnimEditorPaintToolStateDelegate? {
        didSet {
            brushGestureRecognizer.gestureDelegate = delegate
        }
    }
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = AnimEditorBrushToolControlsVC()
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        // TODO: Allow switching brushes
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.paintBrushIDs.first!)
        
        scale = AnimEditorToolSettingsStore
            .brushToolScale
        smoothing = AnimEditorToolSettingsStore
            .brushToolSmoothing
        
        controlsVC.delegate = self
        controlsVC.scale = scale
        controlsVC.smoothing = smoothing
    }
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC
    ) {
        workspaceVC.addOverlayGestureRecognizer(
            brushGestureRecognizer)
        
        toolControlsVC.show(controlsVC)
    }
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC
    ) {
        workspaceVC.removeAllOverlayGestureRecognizers()
        toolControlsVC.show(nil)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }
    
    func toggleToolExpandedOptionsVisible() {
        print("Toggle")
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
