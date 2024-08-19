//
//  EditorTimelineFrameMenuView.swift
//

import UIKit

protocol EditorTimelineFrameMenuViewDelegate: AnyObject {
    
    func onSelectCreateDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int)
    
    func onSelectDeleteDrawing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int)
    
    func onSelectInsertSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int)
    
    func onSelectRemoveSpacing(
        _ v: EditorTimelineFrameMenuView,
        frameIndex: Int)
    
}

class EditorTimelineFrameMenuView: EditorMenuContentView {
    
    weak var delegate: EditorTimelineFrameMenuViewDelegate?
    
    private let frameIndex: Int
    
    init(
        frameIndex: Int,
        hasDrawing: Bool
    ) {
        self.frameIndex = frameIndex
        super.init(frame: .zero)
        
        pinWidth(to: 240)
        
        let stack = UIStackView()
        stack.axis = .vertical
        addSubview(stack)
        stack.pinEdges()
        
        let row1 = RowView(
            title: "Insert Spacing",
            destructive: false)
        stack.addArrangedSubview(row1)
        
        row1.button.addHandler { [weak self] in
            guard let self else { return }
            self.menuView?.dismiss()
            self.delegate?.onSelectInsertSpacing(
                self,
                frameIndex: frameIndex)
        }
        
        stack.addArrangedSubview(RowSeparator())
        
        let row2 = RowView(
            title: "Remove Spacing",
            destructive: false)
        stack.addArrangedSubview(row2)
        
        row2.button.addHandler { [weak self] in
            guard let self else { return }
            self.menuView?.dismiss()
            self.delegate?.onSelectRemoveSpacing(
                self,
                frameIndex: frameIndex)
        }
        
        stack.addArrangedSubview(RowSectionSeparator())
        
        if hasDrawing {
            let row1 = RowView(
                title: "Delete Drawing",
                destructive: true)
            stack.addArrangedSubview(row1)
            
            row1.button.addHandler { [weak self] in
                guard let self else { return }
                self.menuView?.dismiss()
                self.delegate?.onSelectDeleteDrawing(
                    self,
                    frameIndex: frameIndex)
            }
        } else {
            let row1 = RowView(title: "New Drawing")
            stack.addArrangedSubview(row1)
            
            row1.button.addHandler { [weak self] in
                guard let self else { return }
                self.menuView?.dismiss()
                self.delegate?.onSelectCreateDrawing(
                    self,
                    frameIndex: frameIndex)
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private class RowView: UIView {
    
    let button = RowButton()
    
    init(title: String, destructive: Bool = false) {
        super.init(frame: .zero)
        pinHeight(to: 48)
        
        addSubview(button)
        button.pinEdges()
        
        let label = UILabel()
        label.text = title
        label.textColor = destructive ? .systemRed : .editorLabel
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

private class RowSectionSeparator: UIView {
    
    init() {
        super.init(frame: .zero)
        pinHeight(to: 8)
        backgroundColor = UIColor(white: 0, alpha: 0.2)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
