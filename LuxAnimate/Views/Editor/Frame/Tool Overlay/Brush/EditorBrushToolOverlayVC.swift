//
//  EditorBrushToolOverlayVC.swift
//

import UIKit

private let sizeGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class EditorBrushToolOverlayVC: UIViewController {
    
    private let sizeSlider = EditorBrushToolOverlaySlider(
        title: "Size",
        gamma: sizeGamma,
        valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider = EditorBrushToolOverlaySlider(
        title: "Smoothing",
        gamma: smoothingGamma,
        valueDisplayMode: .percent(minValue: 0))
    
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
        stack.addArrangedSubview(smoothingSlider)
    }
    
    var size: Double {
        get { sizeSlider.value }
        set { sizeSlider.value = newValue }
    }
    
    var smoothing: Double {
        get { smoothingSlider.value }
        set { smoothingSlider.value = newValue }
    }
    
}
