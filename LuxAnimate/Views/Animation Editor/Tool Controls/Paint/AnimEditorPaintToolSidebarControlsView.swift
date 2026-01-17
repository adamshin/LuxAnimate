//
//  AnimEditorPaintToolSidebarControlsView.swift
//

import UIKit

private let scaleGamma: Double = 2.0
private let smoothingGamma: Double = 1.5

extension AnimEditorPaintToolSidebarControlsView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onChangeScale(
            _ view: AnimEditorPaintToolSidebarControlsView,
            _ value: Double)
        func onChangeSmoothing(
            _ view: AnimEditorPaintToolSidebarControlsView,
            _ value: Double)
        
    }
    
}

class AnimEditorPaintToolSidebarControlsView: PassthroughView {
    
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
    
    weak var delegate: Delegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        addSubview(stack)
        stack.pinEdges(.leading)
        stack.pin(.centerY)
        
        stack.addArrangedSubview(scaleSlider)
        stack.addArrangedSubview(smoothingSlider)
        
        scaleSlider.delegate = self
        smoothingSlider.delegate = self
    }
    
    func setScale(_ value: Double) {
        scaleSlider.value = value
    }
    
    func setSmoothing(_ value: Double) {
        smoothingSlider.value = value
    }
    
}

extension AnimEditorPaintToolSidebarControlsView:
    AnimEditorToolSidebarSlider.Delegate {
    
    func onChangeValue(
        _ slider: AnimEditorToolSidebarSlider
    ) {
        switch slider {
        case scaleSlider:
            delegate?.onChangeScale(self, slider.value)
            
        case smoothingSlider:
            delegate?.onChangeSmoothing(self, slider.value)
            
        default:
            break
        }
    }
    
}
