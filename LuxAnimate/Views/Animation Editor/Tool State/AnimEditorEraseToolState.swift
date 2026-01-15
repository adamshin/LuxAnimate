//
//  AnimEditorEraseToolState.swift
//

import UIKit
import BrushEngine

@MainActor
class AnimEditorEraseToolState: AnimEditorToolState {

    private let brushGestureRecognizer = BrushGestureRecognizer()

    // TODO: Controls view controller

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

    // MARK: - AnimEditorToolState

    var workspaceOverlayGestureRecognizers: [UIGestureRecognizer] {
        [brushGestureRecognizer]
    }

    var toolControlsVC: UIViewController? {
        // TODO: Return controls VC
        nil
    }

    func setEditInteractionEnabled(_ enabled: Bool) {
        brushGestureRecognizer.isEnabled = enabled
    }

}
