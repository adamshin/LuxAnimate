//
//  EditorMenuPositioningView.swift
//

private let edgeSpacing: CGFloat = 12

import UIKit

class EditorMenuPositioningView: PassthroughView {
    
    var contentView: UIView?
    
    func setContentView(_ view: UIView) {
        addSubview(view)
        contentView = view
    }
    
    func setupConstraints(
        presentation: EditorMenuPresentation
    ) {
        guard let contentView else { return }
        
        contentView.pin(
            .leading, to: self,
            constant: edgeSpacing,
            relation: .greaterOrEqual)
        contentView.pin(
            .trailing, to: self,
            constant: -edgeSpacing,
            relation: .lessOrEqual)
        contentView.pin(
            .top, to: self,
            constant: edgeSpacing, 
            relation: .greaterOrEqual)
        contentView.pin(
            .bottom, to: self,
            constant: -edgeSpacing, 
            relation: .lessOrEqual)
        
        switch presentation.position {
        case .top:
            contentView.pin(
                .centerX, 
                to: presentation.sourceView,
                priority: .defaultHigh)
            contentView.pin(
                .bottom,
                to: presentation.sourceView,
                toAnchor: .top,
                constant: -presentation.spacing,
                priority: .defaultHigh)
        }
    }
    
}
