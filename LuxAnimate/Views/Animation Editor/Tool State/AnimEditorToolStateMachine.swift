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
    
    private(set) var currentToolState: AnimEditorToolState?
    
    func setToolState(_ toolState: AnimEditorToolState) {
        if currentToolState != nil {
            delegate?.toolStateDidEnd(self)
        }
        
        currentToolState = toolState
        
        delegate?.toolStateDidBegin(self,
            workspaceControlsVC: toolState.workspaceControlsVC,
            workspaceGestureRecognizers: toolState.workspaceGestureRecognizers)
    }
    
    func setEditInteractionEnabled(_ enabled: Bool) {
        currentToolState?.setEditInteractionEnabled(enabled)
    }
    
}
