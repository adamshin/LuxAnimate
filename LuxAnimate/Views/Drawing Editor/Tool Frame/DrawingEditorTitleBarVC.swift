//
//  DrawingEditorTitleBarVC.swift
//

import UIKit

class DrawingEditorTitleBarVC: UIViewController {
    
    let bodyView = DrawingEditorTitleBarView()
    
    override func loadView() {
        view = bodyView
    }
    
}
