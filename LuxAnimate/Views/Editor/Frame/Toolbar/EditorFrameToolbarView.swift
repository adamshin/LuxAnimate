//
//  EditorFrameToolbarView.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

class EditorFrameToolbarView: UIView {
    
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
    let eraseButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "eraser.fill",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let traceButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "square.on.square.dashed",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let undoButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "arrow.uturn.backward",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    let redoButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "arrow.uturn.forward",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        
        pinHeight(to: barHeight)
        
        let blurView = ChromeBlurView(
            overlayColor: .editorBarOverlay)
        
        addSubview(blurView)
        blurView.pinEdges()
        blurView.backgroundColor = .editorBarShadow
        
        let shadow = UIView()
        shadow.backgroundColor = .editorBarShadow
        addSubview(shadow)
        shadow.pinEdges(.horizontal)
        shadow.pin(.top, toAnchor: .bottom)
        shadow.pinHeight(to: 1)
        
        // Stacks
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        addSubview(leftStack)
        leftStack.pinEdges(.vertical)
        leftStack.pinEdges(.leading, padding: padding)
        
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        addSubview(rightStack)
        rightStack.pinEdges(.vertical)
        rightStack.pinEdges(.trailing, padding: padding)
        
        // Icons
        leftStack.addArrangedSubview(backButton)
        leftStack.setCustomSpacing(8, after: backButton)
        
        let separator = UIView()
        leftStack.addArrangedSubview(separator)
        separator.pinWidth(to: 16)
        let line = CircleView()
        line.backgroundColor = UIColor(white: 1, alpha: 0.15)
        separator.addSubview(line)
        line.pinWidth(to: 2)
        line.pinHeight(to: 24)
        line.pinCenter(.vertical)
        line.pinEdges(.leading)
        
        leftStack.addArrangedSubview(brushButton)
        leftStack.addArrangedSubview(eraseButton)
        
        rightStack.addArrangedSubview(traceButton)
        rightStack.addArrangedSubview(undoButton)
        rightStack.addArrangedSubview(redoButton)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func selectBrush() {
        brushButton.tintColor = .tint
        eraseButton.tintColor = .editorLabel
    }
    func selectErase() {
        brushButton.tintColor = .editorLabel
        eraseButton.tintColor = .tint
    }
    func setTraceOn(_ on: Bool) {
        traceButton.tintColor = on ?
            .tint : .editorLabel
    }
    
}
