//
//  EditorBrushToolOverlayVC.swift
//

import UIKit

class EditorBrushToolOverlayVC: UIViewController {
    
    private let slider1 = ToolOverlaySlider()
    private let slider2 = ToolOverlaySlider()
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.axis = .vertical
        view.addSubview(stack)
        stack.pinEdges(.leading)
        stack.pin(.centerY)
        
        stack.addArrangedSubview(slider1)
        stack.addArrangedSubview(slider2)
        
        slider1.value = 0.5
        slider2.value = 1
    }
    
}
