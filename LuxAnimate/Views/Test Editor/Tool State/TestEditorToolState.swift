//
//  TestEditorToolState.swift
//

import UIKit

protocol TestEditorToolState: AnyObject {
    
    func beginState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC)
    
    func endState(
        workspaceVC: TestEditorWorkspaceVC,
        toolControlsVC: TestEditorToolControlsVC)
    
}
