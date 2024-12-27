//
//  AnimEditorFrameToolbarToolPickerView.swift
//

import UIKit

// MARK: - Config

private let buttonWidth: CGFloat = 64

private let iconConfig = UIImage.SymbolConfiguration(
    pointSize: 19,
    weight: .medium,
    scale: .medium)

// MARK: - Tools

private let tools: [AnimEditorFrameToolbarVC.Tool] = [
    .paint, .erase,
]

extension AnimEditorFrameToolbarVC.Tool {
    
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

// MARK: - Delegate

extension AnimEditorFrameToolbarToolPickerView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectTool(
            _ v: AnimEditorFrameToolbarToolPickerView,
            tool: AnimEditorFrameToolbarVC.Tool,
            alreadySelected: Bool)
        
    }
    
}

// MARK: - AnimEditorFrameToolbarToolPickerView

class AnimEditorFrameToolbarToolPickerView: UIView {
    
    private let toolButtons: [UIButton]
    
    private var selectedTool: AnimEditorFrameToolbarVC.Tool?
    
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
        let alreadySelected = selectedTool == tool
        
        delegate?.onSelectTool(
            self,
            tool: tool,
            alreadySelected: alreadySelected)
    }
    
    // MARK: - Interface
    
    func update(
        selectedTool: AnimEditorFrameToolbarVC.Tool?
    ) {
        self.selectedTool = selectedTool
        
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
