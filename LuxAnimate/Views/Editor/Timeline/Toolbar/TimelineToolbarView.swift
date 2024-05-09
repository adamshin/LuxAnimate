//
//  TimelineToolbarView.swift
//

import UIKit

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let centerTextWidth: CGFloat = 80

private let frameFont = UIFont.monospacedDigitSystemFont(
    ofSize: 17,
    weight: .medium)

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

private let playIconConfig = UIImage.SymbolConfiguration(
    pointSize: 25,
    weight: .medium,
    scale: .medium)

class TimelineToolbarView: UIView {
    
    let frameLabel = UILabel()
    
    let playButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "play.fill",
            withConfiguration: playIconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let firstFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "backward.end",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let lastFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "forward.end",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let loopButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "arrow.triangle.2.circlepath",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let previousFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.left",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let nextFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let onionSkinButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "square.on.square.dashed",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let layersButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "square.stack.3d.up",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let expandButton = {
        let button = UIButton(type: .system)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    private let expandButtonExpandedImage = UIImage(
        systemName: "chevron.down",
        withConfiguration: iconConfig)
    
    private let expandButtonCollapsedImage = UIImage(
        systemName: "chevron.up",
        withConfiguration: iconConfig)
    
    init() {
        super.init(frame: .zero)
        
        // Left content
        let leftStack = UIStackView()
        leftStack.axis = .horizontal
        
        addSubview(leftStack)
        leftStack.pinEdges(.vertical)
        leftStack.pinEdges(.leading, padding: padding)
        
        leftStack.addArrangedSubview(playButton)
        leftStack.addArrangedSubview(firstFrameButton)
        leftStack.addArrangedSubview(lastFrameButton)
        leftStack.addArrangedSubview(loopButton)
        
        // Center content
        let centerStack = UIStackView()
        centerStack.axis = .horizontal
        
        addSubview(centerStack)
        centerStack.pinEdges(.vertical)
        centerStack.pinCenter(.horizontal)
        
        centerStack.addArrangedSubview(previousFrameButton)
        
        let frameLabelContainer = UIView()
        centerStack.addArrangedSubview(frameLabelContainer)
        frameLabelContainer.pinWidth(to: centerTextWidth)
        
        let frameLabelLozenge = CircleView()
        frameLabelLozenge.layer.cornerCurve = .continuous
        frameLabelContainer.addSubview(frameLabelLozenge)
        frameLabelLozenge.pinEdges(.horizontal)
        frameLabelLozenge.pin(.centerY)
        frameLabelLozenge.pinHeight(to: 32)
        frameLabelLozenge.backgroundColor = UIColor(white: 1, alpha: 0.15)
        
        frameLabelContainer.addSubview(frameLabel)
        frameLabel.pinCenter()
        
        centerStack.addArrangedSubview(nextFrameButton)
        
        // Right content
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        addSubview(rightStack)
        
        rightStack.pinEdges(.vertical)
        rightStack.pinEdges(.trailing, padding: padding)
        
//        rightStack.addArrangedSubview(onionSkinButton)
//        rightStack.addArrangedSubview(layersButton)
        rightStack.addArrangedSubview(expandButton)
        
        setExpanded(false)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setExpanded(_ expanded: Bool) {
        let image = expanded ?
            expandButtonExpandedImage :
            expandButtonCollapsedImage
        expandButton.setImage(image, for: .normal)
    }
    
    func setPlayButtonPlaying(_ playing: Bool) {
        if playing {
            let image = UIImage(
                systemName: "pause.fill",
                withConfiguration: playIconConfig)
            playButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(
                systemName: "play.fill",
                withConfiguration: playIconConfig)
            playButton.setImage(image, for: .normal)
        }
    }
    
    func updateFrameLabel(index: Int, total: Int) {
        let string = NSMutableAttributedString()
        
//        string.append(attributedString(
//            text: "Frame ",
//            font: frameFont,
//            color: .editorLabel))
        
        string.append(attributedString(
            text: "\(index + 1)",
            font: frameFont,
            color: .editorLabel))
//        string.append(attributedString(
//            text: "\u{2000}/\u{2000}",
//            font: frameFont,
//            color: .editorLabelSecondary))
//        string.append(attributedString(
//            text: "\(total)",
//            font: frameFont,
//            color: .editorLabelSecondary))
        
        frameLabel.attributedText = string
    }
    
}

private func attributedString(
    text: String,
    font: UIFont,
    color: UIColor)
-> NSAttributedString {
    
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
    ]
    return NSAttributedString(
        string: text,
        attributes: attributes)
}

