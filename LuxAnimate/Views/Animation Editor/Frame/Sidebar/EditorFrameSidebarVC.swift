//
//  EditorFrameSidebarVC.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

protocol EditorFrameSidebarVCDelegate: AnyObject {
    
    func onSetBrushScale(
        _ vc: EditorFrameSidebarVC,
        _ brushScale: Double)
    
    func onSetBrushSmoothing(
        _ vc: EditorFrameSidebarVC,
        _ brushSmoothing: Double)
    
}

class EditorFrameSidebarVC: UIViewController {
    
    weak var delegate: EditorFrameSidebarVCDelegate?
    
    private let scaleSlider = EditorSidebarSliderContainer(
        title: "Size",
        gamma: scaleGamma,
        valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider = EditorSidebarSliderContainer(
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
        
        stack.addArrangedSubview(scaleSlider)
        stack.addArrangedSubview(smoothingSlider)
        
        scaleSlider.delegate = self
        smoothingSlider.delegate = self
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

extension EditorFrameSidebarVC: EditorSidebarSliderContainerDelegate {
    
    func onChangeValue(_ v: EditorSidebarSliderContainer) {
        if v == scaleSlider {
            delegate?.onSetBrushScale(self, brushScale)
        }
        if v == smoothingSlider {
            delegate?.onSetBrushSmoothing(self, brushSmoothing)
        }
    }
    
}
