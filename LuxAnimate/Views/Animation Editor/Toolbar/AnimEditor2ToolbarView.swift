//
//  AnimEditor2ToolbarView.swift
//

import UIKit

// MARK: - Config

private let barHeight: CGFloat = 48

private let buttonWidth: CGFloat = 64
private let edgePadding: CGFloat = 8

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

// MARK: - Delegate

extension AnimEditor2ToolbarView {
    
    @MainActor
    protocol Delegate: AnyObject {
        func onSelectBack(_ v: AnimEditor2ToolbarView)
        func onSelectOnionSkin(_ v: AnimEditor2ToolbarView)
        func onSelectUndo(_ v: AnimEditor2ToolbarView)
        func onSelectRedo(_ v: AnimEditor2ToolbarView)
    }
    
}

// MARK: - AnimEditor2ToolbarView

class AnimEditor2ToolbarView: PassthroughView {
    
    private let backButton = {
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
        config.contentInsets.leading = 28
        config.contentInsets.trailing = 28
        
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
    
    private let onionSkinButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "square.stack.3d.up",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    private let undoButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "arrow.uturn.backward",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    private let redoButton = {
        let button = UIButton(type: .system)
        let image = UIImage(
            systemName: "arrow.uturn.forward",
            withConfiguration: iconConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .editorLabel
        button.pinWidth(to: buttonWidth)
        return button
    }()
    
    let toolPickerContainer = UIView()
    
    weak var delegate: Delegate?
    
    init() {
        super.init(frame: .zero)
        pinHeight(to: barHeight)
        
        // Bar content
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
        rightStack.pinEdges(.trailing, padding: edgePadding)
        
        // Content
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
        
        leftStack.addArrangedSubview(toolPickerContainer)
        
        rightStack.addArrangedSubview(onionSkinButton)
        rightStack.addArrangedSubview(undoButton)
        rightStack.addArrangedSubview(redoButton)
        
        backButton.addHandler { [weak self] in
            guard let self else { return }
            delegate?.onSelectBack(self)
        }
        onionSkinButton.addHandler { [weak self] in
            guard let self else { return }
            delegate?.onSelectOnionSkin(self)
        }
        undoButton.addHandler { [weak self] in
            guard let self else { return }
            delegate?.onSelectUndo(self)
        }
        redoButton.addHandler { [weak self] in
            guard let self else { return }
            delegate?.onSelectRedo(self)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func update(
        undoEnabled: Bool,
        redoEnabled: Bool
    ) {
        undoButton.isEnabled = undoEnabled
        redoButton.isEnabled = redoEnabled
    }
    
    func update(isOnionSkinOn: Bool) {
        onionSkinButton.tintColor =
            isOnionSkinOn ? .systemBlue : .editorLabel
    }
    
}
