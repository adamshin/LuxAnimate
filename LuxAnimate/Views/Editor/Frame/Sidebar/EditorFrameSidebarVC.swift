//
//  EditorFrameSidebarVC.swift
//

import UIKit

private let defaultSize: Double = 0.2
private let defaultSmoothing: Double = 0

private let sizeGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class EditorFrameSidebarVC: UIViewController {
    
    private let sizeSlider = EditorSidebarSlider(
        title: "Size",
        gamma: sizeGamma,
        valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider = EditorSidebarSlider(
        title: "Smoothing",
        gamma: smoothingGamma,
        valueDisplayMode: .percent(minValue: 0))
    
    private let jogWheelButton = EditorSidebarButton()
    
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
        stack.addArrangedSubview(jogWheelButton)
        stack.addArrangedSubview(smoothingSlider)
        
        size = defaultSize
        smoothing = defaultSmoothing
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
