//
//  TestEditorEraseToolState.swift
//

import UIKit

protocol TestEditorEraseToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: TestEditorEraseToolState,
        quickTap: Bool)

    func onUpdateBrushStroke(
        _ s: TestEditorEraseToolState,
        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: TestEditorEraseToolState)

    func onCancelBrushStroke(
        _ s: TestEditorEraseToolState)
    
}

class TestEditorEraseToolState: TestEditorToolState {
    
    weak var delegate: TestEditorEraseToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = TestEditorEraseToolControlsVC()
    
    func beginState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC
    ) {
        workspaceVC.addToolGestureRecognizer(
            brushGestureRecognizer)
        
        toolControlsVC.show(controlsVC)
    }
    
    func endState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC
    ) {
        workspaceVC.removeAllToolGestureRecognizers()
        toolControlsVC.show(nil)
    }
    
}

