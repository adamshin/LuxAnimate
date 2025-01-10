//
//  AnimEditorToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorToolState: AnyObject {
    
    func beginState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: UIViewController)
    
    func endState(
        workspaceVC: EditorWorkspaceVC,
        toolControlsVC: UIViewController)
    
    func setEditInteractionEnabled(_ enabled: Bool)
    
    func toggleToolExpandedOptionsVisible()
    
}
