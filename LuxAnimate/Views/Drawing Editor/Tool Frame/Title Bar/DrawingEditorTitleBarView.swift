//
//  DrawingEditorTitleBarView.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

class DrawingEditorTitleBarView: UIView {
    
    let backButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.backward",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 22,
                weight: .medium,
                scale: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let clearButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "clear",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let brushButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "paintbrush.pointed.fill",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .editorBar
        clipsToBounds = false
        
        let barView = UIView()
        addSubview(barView)
        barView.pinHeight(to: barHeight)
        barView.pinEdges([.horizontal, .bottom])
        barView.pin(.top, to: safeAreaLayoutGuide)
        
        let shadow = UIView()
        shadow.backgroundColor = .editorBarShadow
        addSubview(shadow)
        shadow.pinEdges(.horizontal)
        shadow.pin(.top, toAnchor: .bottom)
        shadow.pinHeight(to: 1)
        
        // Stacks
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        barView.addSubview(leftStack)
        leftStack.pinEdges(.vertical)
        leftStack.pinEdges(.leading, padding: padding)
        
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        barView.addSubview(rightStack)
        rightStack.pinEdges(.vertical)
        rightStack.pinEdges(.trailing, padding: padding)
        
        // Icons
        leftStack.addArrangedSubview(backButton)
        leftStack.setCustomSpacing(8, after: backButton)
        
        rightStack.addArrangedSubview(clearButton)
        rightStack.addArrangedSubview(brushButton)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
