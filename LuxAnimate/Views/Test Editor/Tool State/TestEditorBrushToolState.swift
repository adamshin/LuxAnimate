//
//  TestEditorBrushToolState.swift
//

import UIKit

protocol TestEditorBrushToolStateDelegate: AnyObject {
    
    func onBeginBrushStroke(
        _ s: TestEditorBrushToolState,
        quickTap: Bool)

    func onUpdateBrushStroke(
        _ s: TestEditorBrushToolState,
        stroke: BrushGestureRecognizer.Stroke)

    func onEndBrushStroke(
        _ s: TestEditorBrushToolState)

    func onCancelBrushStroke(
        _ s: TestEditorBrushToolState)
    
}

class TestEditorBrushToolState: TestEditorToolState {
    
    weak var delegate: TestEditorBrushToolStateDelegate?
    
    private let brushGestureRecognizer = BrushGestureRecognizer()
    private let controlsVC = TestEditorBrushToolControlsVC()
    
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
