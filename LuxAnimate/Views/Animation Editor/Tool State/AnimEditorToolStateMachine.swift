//
//  AnimEditorToolStateMachine.swift
//

import UIKit

extension AnimEditorToolStateMachine {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func workspaceVC(_ s: AnimEditorToolStateMachine)
        -> EditorWorkspaceVC
        
    }
    
}

@MainActor
class AnimEditorToolStateMachine {

    weak var delegate: Delegate?

    private var currentToolState: AnimEditorToolState?

    func setToolState(_ toolState: AnimEditorToolState) {
        guard let delegate else { return }
        
        let workspaceVC = delegate.workspaceVC(self)
        
        currentToolState?.end(workspaceVC: workspaceVC)
        currentToolState = toolState
        toolState.begin(workspaceVC: workspaceVC)
    }

    func setEditInteractionEnabled(_ enabled: Bool) {
        currentToolState?.setEditInteractionEnabled(enabled)
    }

}
