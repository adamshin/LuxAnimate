//
//  TestEditorEraseToolControlsVC.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class TestEditorEraseToolControlsVC: UIViewController {
    
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
        
        scaleSlider.value = TestEditorToolSettingsStore.eraseToolScale
        smoothingSlider.value = TestEditorToolSettingsStore.eraseToolSmoothing
    }
    
}

extension TestEditorEraseToolControlsVC: EditorSidebarSliderContainerDelegate {
    
    func onChangeValue(_ v: EditorSidebarSliderContainer) {
        switch v {
        case scaleSlider:
            let v = scaleSlider.value
            TestEditorToolSettingsStore.eraseToolScale = v
            
        case smoothingSlider:
            let v = smoothingSlider.value
            TestEditorToolSettingsStore.eraseToolSmoothing = v
            
        default:
            break
        }
    }
    
}
