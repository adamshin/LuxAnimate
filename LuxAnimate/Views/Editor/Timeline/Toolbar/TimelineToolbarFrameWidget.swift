//
//  TimelineToolbarFrameWidget.swift
//

import UIKit

private let buttonWidth: CGFloat = 64
private let frameButtonWidth: CGFloat = 88

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

private let numberFont = UIFont.monospacedDigitSystemFont(
    ofSize: 17,
    weight: .medium)

protocol TimelineToolbarFrameWidgetDelegate: AnyObject {
    
    func onSelectPreviousFrame(
        _ v: TimelineToolbarFrameWidget)
    func onSelectNextFrame(
        _ v: TimelineToolbarFrameWidget)
    
}

class TimelineToolbarFrameWidget: UIView {
    
    weak var delegate: TimelineToolbarFrameWidgetDelegate?
    
    private let frameNumberLabel = UILabel()
    
    private let previousFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.left",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    private let nextFrameButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        
        addSubview(stack)
        stack.pinEdges()
        
        stack.addArrangedSubview(previousFrameButton)
        
        let frameButtonContainer = UIView()
        stack.addArrangedSubview(frameButtonContainer)
        frameButtonContainer.pinWidth(to: frameButtonWidth)
        
        let frameLozenge = CircleView()
        frameLozenge.layer.cornerCurve = .continuous
        frameButtonContainer.addSubview(frameLozenge)
        frameLozenge.pinEdges(.horizontal)
        frameLozenge.pin(.centerY)
        frameLozenge.pinHeight(to: 32)
        frameLozenge.backgroundColor = UIColor(white: 1, alpha: 0.15)
        
        frameButtonContainer.addSubview(frameNumberLabel)
        frameNumberLabel.pinCenter()
        frameNumberLabel.font = numberFont
        frameNumberLabel.textColor = .editorLabel
        
        stack.addArrangedSubview(nextFrameButton)
        
        previousFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectPreviousFrame(self)
        }
        nextFrameButton.addHandler { [weak self] in
            guard let self else { return }
            self.delegate?.onSelectNextFrame(self)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setFocusedFrameIndex(_ index: Int) {
        frameNumberLabel.text = "\(index + 1)"
    }
    
}
