//
//  AnimEditorEraseToolState.swift
//

import UIKit
import BrushEngine

@MainActor
protocol AnimEditorEraseToolStateDelegate:
    BrushGestureRecognizer.GestureDelegate { }

class AnimEditorEraseToolState: AnimEditorToolState {
    
    weak var delegate: AnimEditorEraseToolStateDelegate? {
        didSet {
            brushGestureRecognizer.gestureDelegate = delegate
        }
    }
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = AnimEditorEraseToolControlsVC()
    
    private(set) var brush: BrushEngine.Brush?
    private(set) var scale: Double
    private(set) var smoothing: Double
    
    init() {
        brush = try? BrushLibraryManager.loadBrush(
            id: AppConfig.eraseBrushID)
        
        scale = AnimEditorToolSettingsStore
            .eraseToolScale
        smoothing = AnimEditorToolSettingsStore
            .eraseToolSmoothing
        
//        controlsVC.delegate = self
//        controlsVC.scale = scale
//        controlsVC.smoothing = smoothing
    }
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: UIViewController
    ) {
        workspaceVC.addOverlayGestureRecognizer(
            brushGestureRecognizer)
        
//        toolControlsVC.show(controlsVC)
    }
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: UIViewController
    ) {
        workspaceVC.removeAllOverlayGestureRecognizers()
//        toolControlsVC.show(nil)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }
    
    func toggleToolExpandedOptionsVisible() {
        // TODO
    }
    
}

// MARK: - Delegates

//extension AnimEditorEraseToolState: AnimEditorEraseToolControlsVCDelegate {
//    
//    func onChangeScale(_ vc: AnimEditorEraseToolControlsVC) {
//        scale = controlsVC.scale
//        AnimEditorToolSettingsStore
//            .eraseToolScale = scale
//    }
//    func onChangeSmoothing(_ vc: AnimEditorEraseToolControlsVC) {
//        smoothing = controlsVC.smoothing
//        AnimEditorToolSettingsStore.eraseToolSmoothing = smoothing
//    }
//    
//}
