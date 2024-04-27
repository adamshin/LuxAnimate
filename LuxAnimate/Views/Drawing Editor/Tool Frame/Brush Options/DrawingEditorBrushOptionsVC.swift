//
//  DrawingEditorBrushOptionsVC.swift
//

import UIKit

class DrawingEditorBrushOptionsVC: UIViewController {
    
    let bodyView = DrawingEditorBrushOptionsView()
    
    override func loadView() {
        view = bodyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setVisible(false)
        
        bodyView.sizeRowView.value = 0.2
        bodyView.smoothingRowView.value = 0
    }
    
    func setVisible(_ visible: Bool) {
        view.isHidden = !visible
    }
    
    func toggleVisibility() {
        view.isHidden.toggle()
    }
    
    var brushSize: Double { bodyView.sizeRowView.value }
    var smoothing: Double { bodyView.smoothingRowView.value }
    
}
