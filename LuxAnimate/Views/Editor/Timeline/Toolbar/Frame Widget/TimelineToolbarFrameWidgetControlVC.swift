//
//  TimelineToolbarFrameWidgetControlVC.swift
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

protocol TimelineToolbarFrameWidgetControlVCDelegate: AnyObject {
    
    func onChangeFocusedFrame(
        _ vc: TimelineToolbarFrameWidgetControlVC,
        index: Int)
    
}

class TimelineToolbarFrameWidgetControlVC: UIViewController {
    
    weak var delegate: TimelineToolbarFrameWidgetControlVCDelegate?
    
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
    
    private var frameCount = 0
    private var focusedFrameIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = UIStackView()
        stack.axis = .horizontal
        
        view.addSubview(stack)
        stack.pinEdges(.horizontal, padding: 20)
        stack.pinEdges(.vertical)
        
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
        
        previousFrameButton.addTarget(
            self, action: #selector(onSelectPreviousFrame))
        nextFrameButton.addTarget(
            self, action: #selector(onSelectNextFrame))
        
        updateFrameLabel()
    }
    
    @objc private func onSelectPreviousFrame() {
        onSelectFrame(at: focusedFrameIndex - 1)
    }
    
    @objc private func onSelectNextFrame() {
        onSelectFrame(at: focusedFrameIndex + 1)
    }
    
    private func onSelectFrame(at index: Int) {
        let clampedIndex = clamp(index,
            min: 0, 
            max: frameCount - 1)
        
        focusedFrameIndex = clampedIndex
        updateFrameLabel()
        
        delegate?.onChangeFocusedFrame(
            self, index: clampedIndex)
    }
    
    private func updateFrameLabel() {
        frameNumberLabel.text = "\(focusedFrameIndex + 1)"
    }
    
    func setFrameCount(_ frameCount: Int) {
        self.frameCount = frameCount
    }
    
    func setFocusedFrameIndex(_ index: Int) {
        self.focusedFrameIndex = index
        updateFrameLabel()
    }
    
}
