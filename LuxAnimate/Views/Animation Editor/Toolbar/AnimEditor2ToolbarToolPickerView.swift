//
//  AnimEditor2ToolbarToolPickerView.swift
//

import UIKit

// MARK: - Tools

private let tools: [AnimEditor2ToolbarVC.Tool] = [
    .paint,
    .erase,
]

extension AnimEditor2ToolbarVC.Tool {
    
    var name: String {
        switch self {
        case .paint: "Paint"
        case .erase: "Erase"
        }
    }
    
    var imageSystemName: String {
        switch self {
        case .paint: "paintbrush.pointed.fill"
        case .erase: "eraser.fill"
        }
    }
    
}

// MARK: - Config

private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

// MARK: - Delegate

extension AnimEditor2ToolbarToolPickerView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectTool(
            _ v: AnimEditor2ToolbarToolPickerView,
            tool: AnimEditor2ToolbarVC.Tool)
        
    }
    
}

// MARK: - AnimEditor2ToolbarToolPickerView

class AnimEditor2ToolbarToolPickerView: UIView {
    
    private let toolButtons: [UIButton]
    
    weak var delegate: Delegate?
    
    // MARK: - Init
    
    init() {
        toolButtons = tools.map { tool in
            let button = UIButton(type: .system)
            let image = UIImage(
                systemName: tool.imageSystemName,
                withConfiguration: iconConfig)
            button.setImage(image, for: .normal)
            button.pinWidth(to: buttonWidth)
            return button
        }
        
        super.init(frame: .zero)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        addSubview(stack)
        stack.pinEdges()
        
        for button in toolButtons {
            stack.addArrangedSubview(button)
            
            button.addTarget(self,
                action: #selector(onSelectButton))
        }
        
        update(selectedTool: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Handlers
    
    @objc private func onSelectButton(_ button: UIButton) {
        guard
            let index = toolButtons.firstIndex(of: button),
            index < tools.count
        else { return }
        
        let tool = tools[index]
        delegate?.onSelectTool(self, tool: tool)
    }
    
    // MARK: - Interface
    
    func update(
        selectedTool: AnimEditor2ToolbarVC.Tool?
    ) {
        for (index, button) in toolButtons.enumerated() {
            let isSelected = selectedTool == tools[index]
            if isSelected {
                button.tintColor = .appTint
            } else {
                button.tintColor = .editorLabel
            }
        }
    }
    
}
