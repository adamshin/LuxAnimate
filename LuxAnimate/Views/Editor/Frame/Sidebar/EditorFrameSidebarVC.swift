//
//  EditorFrameSidebarVC.swift
//

import UIKit

private let defaultScale: Double = 0.2
private let defaultSmoothing: Double = 0

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class EditorFrameSidebarVC: UIViewController {
    
    private let scaleSlider = EditorSidebarSliderContainer(
        title: "Size",
        gamma: scaleGamma,
        valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider = EditorSidebarSliderContainer(
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
        
        stack.addArrangedSubview(scaleSlider)
        stack.addArrangedSubview(jogWheelButton)
        stack.addArrangedSubview(smoothingSlider)
        
        brushScale = defaultScale
        brushSmoothing = defaultSmoothing
    }
    
    var brushScale: Double {
        get { scaleSlider.value }
        set { scaleSlider.value = newValue }
    }
    
    var brushSmoothing: Double {
        get { smoothingSlider.value }
        set { smoothingSlider.value = newValue }
    }
    
}
