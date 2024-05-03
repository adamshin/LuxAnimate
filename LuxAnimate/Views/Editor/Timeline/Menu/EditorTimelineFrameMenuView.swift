//
//  EditorTimelineFrameMenuView.swift
//

import UIKit

class EditorTimelineFrameMenuView: EditorMenuContentView {
    
    init() {
        super.init(frame: .zero)
        
        pinWidth(to: 240)
        
        let stack = UIStackView()
        stack.axis = .vertical
        addSubview(stack)
        stack.pinEdges()
        
        let row1 = RowView(title: "Copy")
        let row2 = RowView(title: "Delete Drawing")
        let row3 = RowView(title: "Select")
        
        stack.addArrangedSubview(row1)
        stack.addArrangedSubview(RowSeparator())
        stack.addArrangedSubview(row2)
        stack.addArrangedSubview(RowThickSeparator())
        stack.addArrangedSubview(row3)
        
        row1.button.addHandler { [weak self] in
            self?.menuView?.dismiss()
        }
        row2.button.addHandler { [weak self] in
            self?.menuView?.dismiss()
        }
        row3.button.addHandler { [weak self] in
            self?.menuView?.dismiss()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private class RowView: UIView {
    
    let button = RowButton()
    
    init(title: String) {
        super.init(frame: .zero)
        pinHeight(to: 48)
        
        addSubview(button)
        button.pinEdges()
        
        let label = UILabel()
        label.text = title
        label.textColor = .editorLabel
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        addSubview(label)
        label.pinEdges(.leading, padding: 20)
        label.pin(.centerY)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private class RowButton: UIButton {
    
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

private class RowSeparator: UIView {
    
    init() {
        super.init(frame: .zero)
        pinHeight(to: 1)
        backgroundColor = .editorBarShadow
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private class RowThickSeparator: UIView {
    
    init() {
        super.init(frame: .zero)
        pinHeight(to: 8)
        backgroundColor = UIColor(white: 0, alpha: 0.2)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
