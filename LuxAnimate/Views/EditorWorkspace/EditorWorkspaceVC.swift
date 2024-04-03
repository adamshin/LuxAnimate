//
//  EditorWorkspaceVC.swift
//

import UIKit

class EditorWorkspaceVC: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        view = EditorWorkspaceView()
    }
    
}
