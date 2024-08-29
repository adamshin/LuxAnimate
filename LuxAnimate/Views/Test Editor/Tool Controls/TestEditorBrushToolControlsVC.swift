//
//  TestEditorBrushToolControlsVC.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

protocol TestEditorBrushToolControlsVCDelegate: AnyObject {
    func onChangeScale(_ vc: TestEditorBrushToolControlsVC)
    func onChangeSmoothing(_ vc: TestEditorBrushToolControlsVC)
}

class TestEditorBrushToolControlsVC: UIViewController {
    
    weak var delegate: TestEditorBrushToolControlsVCDelegate?
    
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
    
    var scale: Double {
        get { scaleSlider.value }
        set { scaleSlider.value = newValue }
    }
    
    var smoothing: Double {
        get { smoothingSlider.value }
        set { smoothingSlider.value = newValue }
    }
    
}

extension TestEditorBrushToolControlsVC: EditorSidebarSliderContainerDelegate {
    
    func onChangeValue(_ v: EditorSidebarSliderContainer) {
        switch v {
        case scaleSlider:
            delegate?.onChangeScale(self)
        case smoothingSlider:
            delegate?.onChangeSmoothing(self)
        default: 
            break
        }
    }
    
}
