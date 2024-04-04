//
//  EditorWorkspaceVC.swift
//

import UIKit

class EditorWorkspaceVC: UIViewController {
    
    private let bodyView = EditorWorkspaceView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() { view = bodyView }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        bodyView.fitCanvasToBounds(animated: false)
    }
    
    func fitCanvasToBounds() {
        bodyView.fitCanvasToBounds(animated: true)
    }
    
}
