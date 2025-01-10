//
//  AnimEditorToolSidebarSliderPopupView.swift
//

import UIKit

class AnimEditorToolSidebarSliderPopupView: UIView {
    
    private let valueDisplayMode:
        AnimEditorToolSidebarSlider.ValueDisplayMode
    
    private let cardView = EditorMenuCardView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    init(
        title: String,
        valueDisplayMode:
        AnimEditorToolSidebarSlider
            .ValueDisplayMode
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
        titleLabel.font = .systemFont(
            ofSize: 15, weight: .medium)
        titleLabel.text = title
        
        stack.addArrangedSubview(valueLabel)
        valueLabel.textColor = .editorLabel
        valueLabel.font = .monospacedDigitSystemFont(
            ofSize: 21, weight: .medium)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setVisible(_ visible: Bool, animated: Bool) {
        let update = {
            if visible {
                self.alpha = 1
                self.transform = .identity
            } else {
                self.alpha = 0
                self.transform = CGAffineTransform(
                    scaleX: 0.9, y: 0.9)
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2) { update() }
        } else {
            update()
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
