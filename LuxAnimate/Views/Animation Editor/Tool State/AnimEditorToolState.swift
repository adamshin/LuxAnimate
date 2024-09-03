//
//  AnimEditorToolState.swift
//

import UIKit

protocol AnimEditorToolState: AnyObject {
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
}
