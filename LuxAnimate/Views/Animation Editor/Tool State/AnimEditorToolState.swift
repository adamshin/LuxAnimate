//
//  AnimEditorToolState.swift
//

import UIKit

protocol AnimEditorToolState: AnyObject {
    
    func beginState(
        workspaceVC: AnimEditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
    func endState(
        workspaceVC: AnimEditorWorkspaceVC,
        toolControlsVC: AnimEditorToolControlsVC)
    
}
