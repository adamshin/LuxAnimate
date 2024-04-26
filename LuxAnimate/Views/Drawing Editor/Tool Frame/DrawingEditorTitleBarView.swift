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

private let toolGroup1: [String] = [
    "paintbrush.pointed.fill",
    "eraser.fill",
    "tag.fill",
    "location.fill",
    "lasso",
]

private let toolGroup2: [String] = [
    "square.stack.3d.up",
    "ellipsis",
]

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
    
    let colorButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "circle.inset.filled",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 24,
                weight: .light,
                scale: .medium))
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
        shadow.pinHeight(to: 0.5)
        
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
        
//        let centerStack = UIStackView()
//        centerStack.axis = .horizontal
//        barView.addSubview(centerStack)
//        centerStack.pinEdges(.vertical)
//        centerStack.pinCenter(.horizontal)
        
        // Icons
        leftStack.addArrangedSubview(backButton)
        leftStack.setCustomSpacing(8, after: backButton)
        
        let separator = UIView()
        separator.pinWidth(to: 16)
//        separator.pinWidth(to: 32)
        let line = CircleView()
        line.backgroundColor = .white.withAlphaComponent(0.2)
        line.pinWidth(to: 2)
        line.pinHeight(to: 24)
        separator.addSubview(line)
        line.pinCenter(.vertical)
        line.pinEdges(.leading)
//        line.pinCenter()
        leftStack.addArrangedSubview(separator)
        
        for (index, imageName) in toolGroup1.enumerated() {
            let tintColor: UIColor = if index == 0 {
                .tint
            } else {
                .editorLabel
            }
            
            let image = UIImage(
                systemName: imageName,
                withConfiguration: iconConfig)
            
            let button = UIButton(type: .system)
            button.setImage(image, for: .normal)
            button.tintColor = tintColor
            button.pinWidth(to: buttonWidth)
            
            leftStack.addArrangedSubview(button)
//            rightStack.addArrangedSubview(button)
//            centerStack.addArrangedSubview(button)
        }
        
//        let separator = UIView()
//        separator.pinWidth(to: 32)
//        let line = CircleView()
//        line.backgroundColor = .white.withAlphaComponent(0.2)
//        line.pinWidth(to: 2)
//        line.pinHeight(to: 24)
//        separator.addSubview(line)
//        line.pinCenter()
//        rightStack.addArrangedSubview(separator)
        
        rightStack.addArrangedSubview(colorButton)
        
        for imageName in toolGroup2 {
            let image = UIImage(
                systemName: imageName,
                withConfiguration: iconConfig)
            
            let button = UIButton(type: .system)
            button.setImage(image, for: .normal)
            button.tintColor = .editorLabel
            button.pinWidth(to: buttonWidth)
            
            rightStack.addArrangedSubview(button)
        }
        
//        let circle = CircleView()
//        circle.pinSize(to: 40)
//        circle.backgroundColor = .white.withAlphaComponent(0.2)
//        addSubview(circle)
//        circle.pinCenter(to: rightStack.arrangedSubviews[0])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
