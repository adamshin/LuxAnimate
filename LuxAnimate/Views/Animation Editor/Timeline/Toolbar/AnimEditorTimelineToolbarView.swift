//
//  AnimEditorTimelineToolbarView.swift
//

import UIKit

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

private let playIconConfig = UIImage.SymbolConfiguration(
    pointSize: 25,
    weight: .medium,
    scale: .medium)

class AnimEditorTimelineToolbarView: UIView {
    
    let frameWidget =
        AnimEditorTimelineToolbarFrameWidget()
    
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
    
    let expandToggleButton = {
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
        addSubview(frameWidget)
        frameWidget.pin(.centerX)
        frameWidget.pinEdges(.vertical)
        
        // Right content
        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        addSubview(rightStack)
        
        rightStack.pinEdges(.vertical)
        rightStack.pinEdges(.trailing, padding: padding)
        
        rightStack.addArrangedSubview(expandToggleButton)
        
        setExpanded(false)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setExpanded(_ expanded: Bool) {
        let image = expanded ?
            expandButtonExpandedImage :
            expandButtonCollapsedImage
        expandToggleButton.setImage(image, for: .normal)
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
    
}
