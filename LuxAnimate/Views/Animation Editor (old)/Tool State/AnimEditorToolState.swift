//
//  AnimEditorToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorToolState: AnyObject {
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
    func setEditInteractionEnabled(_ enabled: Bool)
    
    func toggleToolExpandedOptionsVisible()
    
}
