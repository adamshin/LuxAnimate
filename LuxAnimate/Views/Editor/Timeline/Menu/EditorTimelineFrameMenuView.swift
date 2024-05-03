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
        
        stack.addArrangedSubview(RowView(title: "Item 1"))
        stack.addArrangedSubview(RowSeparator())
        stack.addArrangedSubview(RowView(title: "Item 2"))
        stack.addArrangedSubview(RowSeparator())
        stack.addArrangedSubview(RowView(title: "Item 3"))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private class RowView: UIView {
    
    init(title: String) {
        super.init(frame: .zero)
        pinHeight(to: 48)
        
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

class RowSeparator: UIView {
    
    init() {
        super.init(frame: .zero)
        pinHeight(to: 1)
        backgroundColor = .editorBarShadow
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
