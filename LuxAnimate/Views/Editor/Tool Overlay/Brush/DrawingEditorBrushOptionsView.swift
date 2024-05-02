//
//  DrawingEditorBrushOptionsView.swift
//

import UIKit

class DrawingEditorBrushOptionsView: PassthroughView {
    
    let bgButton = UIButton()
    
    let sizeRowView = EditorSliderRowView(
        title: "Size",
        valueStyle: .percentage,
        minValue: 0.01,
        gamma: 2.0)
    
    let smoothingRowView = EditorSliderRowView(
        title: "Smoothing",
        valueStyle: .percentage,
        gamma: 1.5)
    
    init() {
        super.init(frame: .zero)
        
        addSubview(bgButton)
        bgButton.backgroundColor = .clear
        bgButton.pinEdges()
        
        let card = UIView()
        card.backgroundColor = .editorBar
        card.layer.cornerRadius = 24
        card.layer.cornerCurve = .continuous
        
        addSubview(card)
        card.pinEdges([.top, .trailing], padding: 12)
        card.pinWidth(to: 320)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        card.addSubview(contentStack)
        contentStack.pinEdges(padding: 24)
        
        contentStack.addArrangedSubview(sizeRowView)
        contentStack.addArrangedSubview(smoothingRowView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

// MARK: - Row Views

class EditorSliderRowView: UIView {
    
    enum ValueStyle {
        case percentage
    }
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    
    private let valueStyle: ValueStyle
    private let minValue: Double
    private let gamma: Double
    
    init(
        title: String,
        valueStyle: ValueStyle,
        minValue: Double = 0,
        gamma: Double = 1
    ) {
        self.valueStyle = valueStyle
        self.minValue = minValue
        self.gamma = gamma
        
        super.init(frame: .zero)
        
        let vStack = UIStackView()
        vStack.axis = .vertical
        addSubview(vStack)
        vStack.pinEdges()
        
        let titleContainer = UIView()
        vStack.addArrangedSubview(titleContainer)
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .editorLabel
        titleLabel.text = title
        
        titleContainer.addSubview(titleLabel)
        titleContainer.pin(.height, to: titleLabel)
        titleLabel.pin(.centerY)
        titleLabel.pinEdges(.leading)
        
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        valueLabel.textColor = .editorLabelSecondary
        valueLabel.textAlignment = .right
        
        titleContainer.addSubview(valueLabel)
        valueLabel.pin(.centerY)
        valueLabel.pinEdges(.trailing)
        
        let sliderContainer = UIView()
        vStack.addArrangedSubview(sliderContainer)
        sliderContainer.pinHeight(to: 44)
        
        sliderContainer.addSubview(slider)
        slider.pinEdges()
        slider.addTarget(
            self, action: #selector(onSliderChange),
            for: .valueChanged)
        
        value = 0
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func onSliderChange() {
        updateValueLabel()
    }
    
    private func updateValueLabel() {
        switch valueStyle {
        case .percentage:
            valueLabel.text = String(
                format: "%.0f%%",
                value * 100)
        }
    }
    
    var value: Double {
        get {
            let v = pow(Double(slider.value), gamma)
            return max(v, minValue)
        }
        set {
            let v = pow(newValue, 1/gamma)
            slider.value = Float(v)
            updateValueLabel()
        }
    }
    
}
