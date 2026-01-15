//
//  AnimEditorToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorToolState: AnyObject {
    
    var workspaceOverlayGestureRecognizers: [UIGestureRecognizer] { get }
    var toolControlsVC: UIViewController? { get }
    
    func setEditInteractionEnabled(_ enabled: Bool)
    
}
