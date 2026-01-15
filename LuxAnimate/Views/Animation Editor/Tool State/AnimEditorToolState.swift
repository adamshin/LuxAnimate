//
//  AnimEditorToolState.swift
//

import UIKit

@MainActor
protocol AnimEditorToolState: AnyObject {

    func begin(workspaceVC: EditorWorkspaceVC)
    func end(workspaceVC: EditorWorkspaceVC)

    func setEditInteractionEnabled(_ enabled: Bool)

}
