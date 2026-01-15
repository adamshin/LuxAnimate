//
//  AnimEditorToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorToolState: AnyObject {
    
    var workspaceControlsVC: UIViewController? { get }
    var workspaceGestureRecognizers: [UIGestureRecognizer] { get }
    
    func setEditInteractionEnabled(_ enabled: Bool)
    
}
