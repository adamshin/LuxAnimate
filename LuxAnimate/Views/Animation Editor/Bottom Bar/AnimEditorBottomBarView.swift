//
//  AnimEditorBottomBarView.swift
//

import UIKit

private let barHeight: CGFloat = 48

private let padding: CGFloat = 8
private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

private let numberFont = UIFont.monospacedDigitSystemFont(
    ofSize: 17,
    weight: .medium)

class AnimEditorBottomBarView: UIView {
    
    private let frameLabel = UILabel()
    
    let prevFrameButton = {
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
    
    private var activeFrameIndex = 0
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        
        pinHeight(to: barHeight)
        
        let blurView = ChromeBlurView(
            overlayColor: .editorBarOverlay)
        
        addSubview(blurView)
        blurView.pinEdges([.horizontal, .top])
        blurView.pinEdges(.bottom, padding: -40)
        blurView.backgroundColor = .editorBarShadow
        
        let shadow = UIView()
        shadow.backgroundColor = .editorBarShadow
        addSubview(shadow)
        shadow.pinEdges(.horizontal)
        shadow.pin(.bottom, toAnchor: .top)
        shadow.pinHeight(to: 1)
        
        let centerStack = UIStackView()
        centerStack.axis = .horizontal
        addSubview(centerStack)
        centerStack.pinEdges(.vertical)
        centerStack.pin(.centerX)
        
        centerStack.addArrangedSubview(prevFrameButton)
        centerStack.addArrangedSubview(frameLabel)
        centerStack.addArrangedSubview(nextFrameButton)
        
        frameLabel.textAlignment = .center
        frameLabel.pinWidth(to: 80)
        frameLabel.font = numberFont
        frameLabel.textColor = .editorLabel
        
        updateFrameLabel()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func updateFrameLabel() {
        frameLabel.text = "\(activeFrameIndex + 1)"
    }
    
    func setActiveFrameIndex(_ index: Int) {
        self.activeFrameIndex = index
        updateFrameLabel()
    }
    
}
