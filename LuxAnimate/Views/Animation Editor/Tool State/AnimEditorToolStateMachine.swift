//
//  AnimEditorToolStateMachine.swift
//

import UIKit

extension AnimEditorToolStateMachine {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func toolStateDidEnd(
            _ machine: AnimEditorToolStateMachine)
        
        func toolStateDidBegin(
            _ machine: AnimEditorToolStateMachine,
            workspaceOverlayGestureRecognizers: [UIGestureRecognizer],
            toolControlsVC: UIViewController?)
        
    }
    
}

@MainActor
class AnimEditorToolStateMachine {
    
    weak var delegate: Delegate?
    
    private(set) var currentToolState: AnimEditorToolState?
    
    func setToolState(_ toolState: AnimEditorToolState) {
        if currentToolState != nil {
            delegate?.toolStateDidEnd(self)
        }
        
        currentToolState = toolState
        
        delegate?.toolStateDidBegin(
            self,
            workspaceOverlayGestureRecognizers: toolState.workspaceOverlayGestureRecognizers,
            toolControlsVC: toolState.toolControlsVC)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        currentToolState?.setEditInteractionEnabled(enabled)
    }
    
}
