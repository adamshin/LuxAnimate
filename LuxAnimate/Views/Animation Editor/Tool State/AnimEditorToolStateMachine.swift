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
            workspaceControlsVC: UIViewController?,
            workspaceGestureRecognizers: [UIGestureRecognizer])
        
    }
    
}

@MainActor
class AnimEditorToolStateMachine {
    
    weak var delegate: Delegate?
    
    private(set) var toolState: AnimEditorToolState?
    
    func setToolState(_ newToolState: AnimEditorToolState) {
        if toolState != nil {
            delegate?.toolStateDidEnd(self)
        }
        
        toolState = newToolState
        
        delegate?.toolStateDidBegin(
            self,
            workspaceControlsVC: newToolState.workspaceControlsVC,
            workspaceGestureRecognizers: newToolState.workspaceGestureRecognizers)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        toolState?.setEditInteractionEnabled(enabled)
    }
    
}
