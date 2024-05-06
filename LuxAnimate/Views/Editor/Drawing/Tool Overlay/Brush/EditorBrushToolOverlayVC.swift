//
//  EditorBrushToolOverlayVC.swift
//

import UIKit

class EditorBrushToolOverlayVC: UIViewController {
    
    private let sizeSlider = ToolOverlaySlider()
    private let opacitySlider = ToolOverlaySlider()
    
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
        
        stack.addArrangedSubview(sizeSlider)
        stack.addArrangedSubview(opacitySlider)
        
        sizeSlider.value = 0.5
        opacitySlider.value = 1
    }
    
    var size: Double { sizeSlider.value }
    var opacity: Double { opacitySlider.value }
    
}
