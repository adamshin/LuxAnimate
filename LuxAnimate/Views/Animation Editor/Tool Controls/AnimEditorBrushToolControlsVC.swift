//
//  AnimEditorBrushToolControlsVC.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

@MainActor
protocol AnimEditorBrushToolControlsVCDelegate: AnyObject {
    func onChangeScale(_ vc: AnimEditorBrushToolControlsVC)
    func onChangeSmoothing(_ vc: AnimEditorBrushToolControlsVC)
}

class AnimEditorBrushToolControlsVC: UIViewController {
    
    weak var delegate: AnimEditorBrushToolControlsVCDelegate?
    
    private let scaleSlider = AnimEditorToolSidebarSliderContainer(
        title: "Size",
        gamma: scaleGamma,
        valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider = AnimEditorToolSidebarSliderContainer(
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

extension AnimEditorBrushToolControlsVC:
    AnimEditorToolSidebarSliderContainer.Delegate {
    
    func onChangeValue(_ v: AnimEditorToolSidebarSliderContainer) {
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
