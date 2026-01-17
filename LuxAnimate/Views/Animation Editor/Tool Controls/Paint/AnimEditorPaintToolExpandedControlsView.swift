//
//  AnimEditorPaintToolExpandedControlsView.swift
//

import UIKit

private let outsidePadding: CGFloat = 12
private let menuWidth: CGFloat = 240
private let rowHeight: CGFloat = 48
private let labelHPadding: CGFloat = 20
private let fontSize: CGFloat = 17

extension AnimEditorPaintToolExpandedControlsView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBrush(
            _ view: AnimEditorPaintToolExpandedControlsView,
            id: String)
        
    }
    
}

class AnimEditorPaintToolExpandedControlsView: PassthroughView {
    
    weak var delegate: Delegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let cardView = AnimEditorToolSidebarCardView()
        addSubview(cardView)
        cardView.pinEdges([.leading, .top], padding: outsidePadding)
        cardView.pinWidth(to: menuWidth)
        
        let stack = UIStackView()
        stack.axis = .vertical
        cardView.contentView.addSubview(stack)
        stack.pinEdges()
        
        for brushID in AppConfig.paintBrushIDs {
            let row = createBrushRow(id: brushID)
            stack.addArrangedSubview(row)
        }
    }
    
    private func createBrushRow(id: String) -> UIView {
        let row = UIView()
        row.pinHeight(to: rowHeight)
        
        let button = BrushButton()
        row.addSubview(button)
        button.pinEdges()
        
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.onSelectBrush(self, id: id)
            },
            for: .primaryActionTriggered)
        
        let label = UILabel()
        label.text = id
        label.textColor = .editorLabel
        label.font = .systemFont(ofSize: fontSize, weight: .regular)
        
        row.addSubview(label)
        label.pinEdges(.leading, padding: labelHPadding)
        label.pin(.centerY)
        
        return row
    }
    
}

private class BrushButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor(white: 1, alpha: 0.15)
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.backgroundColor = .clear
                }
            }
        }
    }
    
}
