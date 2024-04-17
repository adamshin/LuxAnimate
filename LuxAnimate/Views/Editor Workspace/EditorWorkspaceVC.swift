//
//  EditorWorkspaceVC.swift
//

import UIKit

class EditorWorkspaceVC: UIViewController {
    
    private let bodyView = EditorWorkspaceView()
    
//    private let canvasVC = CanvasVC()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() { view = bodyView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        addChild(canvasVC, to: bodyView.canvasView)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        bodyView.fitCanvasToBounds(animated: false)
    }
    
    func fitCanvasToBounds() {
        bodyView.fitCanvasToBounds(animated: true)
    }
    
}
