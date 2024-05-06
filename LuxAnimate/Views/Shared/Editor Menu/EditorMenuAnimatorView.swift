//
//  EditorMenuAnimatorView.swift
//

import UIKit

private let animateInDuration: TimeInterval = 0.35
private let animateInBounce: TimeInterval = 0.3

private let animateOutDuration: TimeInterval = 0.35
private let animateOutBounce: TimeInterval = 0.3

private let collapsedScale: CGFloat = 0.4

private let sourceViewHighlightedAlpha: CGFloat = 0.5
private let sourceViewHighlightedScale: CGFloat = (64 + 0) / 64

class EditorMenuAnimatorView: UIView {
    
    func showPresentAnimation(
        presentation: EditorMenuPresentation
    ) {
        let t = collapsedTransform()

        alpha = 0
        transform = t

        UIView.animate(
            springDuration: animateInDuration,
            bounce: animateInBounce,
            options: [.allowUserInteraction]
        ) {
            alpha = 1
            transform = .identity
            
            switch presentation.sourceViewEffect {
            case .none:
                break
            case .fade:
                presentation.sourceView.alpha = sourceViewHighlightedAlpha
                
                presentation.sourceView.transform = CGAffineTransform(
                    scaleX: sourceViewHighlightedScale,
                    y: sourceViewHighlightedScale)
            }
        }
    }
    
    func showDismissAnimation(
        presentation: EditorMenuPresentation,
        completion: @escaping () -> Void
    ) {
        let t = collapsedTransform()

        UIView.animate(
            springDuration: animateOutDuration,
            bounce: animateOutBounce,
            options: [.allowUserInteraction]
        ) {
            alpha = 0
            transform = t
            
            presentation.sourceView.alpha = 1
            presentation.sourceView.transform = .identity

        } completion: { _ in
            completion()
        }
    }
    
    private func collapsedTransform() -> CGAffineTransform {
        layoutIfNeeded()
        
        let scale = CGAffineTransform(
            scaleX: collapsedScale,
            y: collapsedScale)
        
        let translate = CGAffineTransform(
            translationX: 0,
            y: bounds.height * (1 - collapsedScale) / 2)
        
        return scale.concatenating(translate)
    }
    
}
