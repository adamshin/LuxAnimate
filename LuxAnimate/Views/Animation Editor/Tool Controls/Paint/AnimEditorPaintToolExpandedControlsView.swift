//
//  AnimEditorPaintToolExpandedControlsView.swift
//

import UIKit

extension AnimEditorPaintToolExpandedControlsView {
    
    @MainActor
    protocol Delegate: AnyObject {
        
        func onSelectBrush(
            _ view: AnimEditorPaintToolExpandedControlsView,
            id: String)
        
    }
    
}

class AnimEditorPaintToolExpandedControlsView: UIView {
    
    weak var delegate: Delegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        addSubview(stack)
        stack.pinEdges()
        
        for brushID in AppConfig.paintBrushIDs {
            let button = createBrushButton(id: brushID)
            stack.addArrangedSubview(button)
        }
    }
    
    private func createBrushButton(id: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(id, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                self.delegate?.onSelectBrush(self, id: id)
            },
            for: .primaryActionTriggered)
        return button
    }
    
}
