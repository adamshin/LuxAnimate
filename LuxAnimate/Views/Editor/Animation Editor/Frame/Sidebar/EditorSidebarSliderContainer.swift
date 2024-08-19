//
//  EditorSidebarSliderContainer.swift
//

import UIKit

protocol EditorSidebarSliderContainerDelegate: AnyObject {
    func onChangeValue(_ v: EditorSidebarSliderContainer)
}

class EditorSidebarSliderContainer: UIView {
    
    weak var delegate: EditorSidebarSliderContainerDelegate?
    
    enum ValueDisplayMode {
        case percent(minValue: Int)
    }
    
    private let gamma: Double
    
    private let slider = EditorSidebarSlider()
    private let popupView: PopupView
    
    init(
        title: String,
        gamma: Double,
        valueDisplayMode: ValueDisplayMode
    ) {
        self.gamma = gamma
        
        popupView = PopupView(
            title: title,
            valueDisplayMode: valueDisplayMode)
        
        super.init(frame: .zero)
        
        addSubview(slider)
        slider.pinEdges()
        
        addSubview(popupView)
        popupView.pin(.centerY)
        popupView.pin(.leading, toAnchor: .trailing)
        
        slider.delegate = self
        
        popupView.setVisible(false, animated: false)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    var value: Double {
        get {
            pow(slider.value, gamma)
        }
        set {
            slider.value = pow(newValue, 1/gamma)
        }
    }
    
}

extension EditorSidebarSliderContainer: EditorSidebarSliderDelegate {
    
    func onBeginPress(_ v: EditorSidebarSlider) {
        popupView.setVisible(true, animated: true)
    }
    
    func onEndPress(_ v: EditorSidebarSlider) {
        popupView.setVisible(false, animated: true)
    }
    
    func onChangeValue(_ v: EditorSidebarSlider) {
        popupView.updateValue(value)
        delegate?.onChangeValue(self)
    }
    
}

private class PopupView: UIView {
    
    private let valueDisplayMode: EditorSidebarSliderContainer.ValueDisplayMode
    
    private let cardView = EditorMenuCardView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    init(
        title: String,
        valueDisplayMode: EditorSidebarSliderContainer.ValueDisplayMode
    ) {
        self.valueDisplayMode = valueDisplayMode
        super.init(frame: .zero)
        
        pinWidth(to: 110)
        pinHeight(to: 110)
        
        addSubview(cardView)
        cardView.pinEdges()
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        cardView.addSubview(stack)
        stack.pinCenter()
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.textColor = .editorLabel
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.text = title
        
        stack.addArrangedSubview(valueLabel)
        valueLabel.textColor = .editorLabel
        valueLabel.font = .monospacedDigitSystemFont(
            ofSize: 21, weight: .medium)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setVisible(_ visible: Bool, animated: Bool) {
        UIView.animate(springDuration: 0.2) {
            if visible {
                alpha = 1
                transform = .identity
            } else {
                alpha = 0
                transform = CGAffineTransform(
                    scaleX: 0.9, y: 0.9)
            }
        }
    }
    
    func updateValue(_ value: Double) {
        switch valueDisplayMode {
        case .percent(let minValue):
            let percentValue = Int((value * 100).rounded())
            let clampedValue = max(minValue, percentValue)
            valueLabel.text = "\(clampedValue)%"
        }
    }
    
}
