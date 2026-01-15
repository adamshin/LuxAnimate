//
//  AnimEditorBrushToolControlsVC.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

class AnimEditorBrushToolControlsVC:
    UIViewController {
    
    private let scaleSlider =
        AnimEditorToolSidebarSlider(
            title: "Size",
            gamma: scaleGamma,
            valueDisplayMode: .percent(minValue: 1))
    
    private let smoothingSlider =
        AnimEditorToolSidebarSlider(
            title: "Smoothing",
            gamma: smoothingGamma,
            valueDisplayMode: .percent(minValue: 0))
    
    override func loadView() {
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        scaleSlider.value =
            AnimEditorToolSettingsStore
                .brushToolScale
        
        smoothingSlider.value =
            AnimEditorToolSettingsStore
                .brushToolSmoothing
    }
    
    private func setupUI() {
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
    
}

extension AnimEditorBrushToolControlsVC:
    AnimEditorToolSidebarSlider.Delegate {
    
    func onChangeValue(
        _ v: AnimEditorToolSidebarSlider
    ) {
        switch v {
        case scaleSlider:
            AnimEditorToolSettingsStore
                .brushToolScale = v.value
            
        case smoothingSlider:
            AnimEditorToolSettingsStore
                .brushToolSmoothing = v.value
            
        default:
            break
        }
    }
    
}
