//
//  AnimEditorToolbarView.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

class AnimEditorToolbarView: UIView {
    
    let backButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Done"
        config.baseForegroundColor = .editorLabel
        config.titleTextAttributesTransformer = .init { attr in
            var newAttr = attr
            newAttr.font = .systemFont(
                ofSize: 17,
                weight: .medium)
            return newAttr
        }
        config.contentInsets.leading = 26
        config.contentInsets.trailing = 26
        
        let button = UIButton(configuration: config)
        button.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.configuration?.baseForegroundColor =
                    .editorLabel.withAlphaComponent(0.2)
            default:
                button.configuration?.baseForegroundColor =
                    .editorLabel
            }
        }
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
    
    let paintButton = {
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
        leftStack.pinEdges(.leading)
        
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        addSubview(rightStack)
        rightStack.pinEdges(.vertical)
        rightStack.pinEdges(.trailing, padding: padding)
        
        // Icons
        leftStack.addArrangedSubview(backButton)
        
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
        
        leftStack.addArrangedSubview(paintButton)
        leftStack.addArrangedSubview(eraseButton)
        
        rightStack.addArrangedSubview(undoButton)
        rightStack.addArrangedSubview(redoButton)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func selectPaintTool() {
        paintButton.tintColor = .tint
        eraseButton.tintColor = .editorLabel
    }
    func selectEraseTool() {
        paintButton.tintColor = .editorLabel
        eraseButton.tintColor = .tint
    }
    
}
